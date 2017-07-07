#!/usr/bin/swift
//
//  main.swift
//  semlog
//
//  Created by Henrik Hartz on 29/06/2017.
//  Copyright © 2017 Henrik Hartz. All rights reserved.
//

import Foundation

func usage() {
    let executable = (CommandLine.arguments[0] as NSString).lastPathComponent
    print("usage: ")
    print("pipe output from e.g. git to \(executable).")
    print("or")
    print("\(executable) --file=/path/to/file to format a text file")
}

let args = CommandLine.arguments
var changes = ""

func exec(_ path: String, _ args: [String]) -> String? {
    let execute = Process()
    execute.launchPath = path
    execute.arguments = args

    let outPipe = Pipe()
    execute.standardOutput = outPipe
    execute.launch()

    let data = outPipe.fileHandleForReading.readDataToEndOfFile()
    if let string = String.init(data: data, encoding: .utf8), string.characters.count > 0 {
        return string.trimmed
    }
    return nil
}

if args.contains("--help") || args.contains("-h") {
    usage()
    exit(0)
}

if let file = args.first(where: { $0.contains("--file") })?.components(separatedBy: "--file=").last {
    if let fileData = FileManager.default.contents(atPath: file),
        let fileString = String.init(data: fileData, encoding: .utf8) {
        changes = fileString
    } else {
        print("unable to open or read \"\(file)\"")
        exit(-1)
    }
}

if args.count == 1 {
    while let inputData = readLine() {
        changes += "\(inputData)\n"
    }
}

if args.contains("--release") {

    var build = 0
    let plistBuddy = "/usr/libexec/PlistBuddy"
    let git = "/usr/local/bin/git"
    let plist = args.first(where: { $0.contains("--plist=") })?.components(separatedBy: "=").last ?? "Info.plist"

    if !FileManager.default.fileExists(atPath: plist) {
        print("could not find plist \(plist). You can specify a path using --plist=path/to/Info.plist")
        exit(-1)
    }

    // find the current build number
    if let buildString = exec(plistBuddy, ["-c", "Print CFBundleVersion", plist])?.trimmed,
        let buildNumber = Int.init(buildString) {
        build = buildNumber
    }

    // increment the build number
    build += 1
    // set the new build number
    _ = exec(plistBuddy, ["-c", "Set :CFBundleVersion \(build)", plist])

    // find the current version, defaults to '0.1.0' CFBundleShortVersionString
    var version = (exec(plistBuddy, ["-c", "Print CFBundleShortVersionString", plist]) ?? "0.1.0").trimmed
    var versionFields = version.components(separatedBy: ".")

    // increment maj,min,maint if needed
    if args.contains("maintenance"), let maintenance = Int.init(versionFields[2]) {
        versionFields[2] = "\(maintenance + 1)"
    }
    if args.contains("minor"), let minor = Int.init(versionFields[1]) {
        versionFields[2] = "0"
        versionFields[1] = "\(minor + 1)"
    }
    if args.contains("major"), let major = Int.init(versionFields[0]) {
        versionFields[2] = "0"
        versionFields[1] = "0"
        versionFields[0] = "\(major + 1)"
    }

    version = versionFields.joined(separator: ".")
    // set the updated values
    _ = exec(plistBuddy, ["-c", "Set :CFBundleShortVersionString \(version)", plist])

    // find changes since last tag
    guard let lastTag = exec(git, ["describe", "--tags", "--abbrev=0"]), let changes = exec(git, ["shortlog", "\(lastTag)..HEAD"]), changes.characters.count > 0 else {
        print("no changes")
        exit(0)
    }

    let semlog = SemanticLog(with: changes)

    // commit the new versions
    _ = exec(git, ["add", plist])
    _ = exec(git, ["commit", "-m", "chore: bump to \(version)-\(build)"])
    var tagArguments = ["tag", "-a"]
    var output = semlog.output

    if let displayName = exec(plistBuddy, ["-c", "Print CFBundleDisplayName", plist])?.trimmed {
        output = displayName + " \(version)-\(build)\n\n" + output
    }

    if output.characters.count > 0 {
        tagArguments.append("-m")
        tagArguments.append("\(output)")
    }
    tagArguments.append("\(version)-\(build)")
    let gitTag = exec(git, tagArguments)

    print("comitted and tagged \(version)-\(build). Opening changelog in default text editor..")
    let open = Process()
    open.launchPath = "/usr/bin/open"
    open.arguments = ["-t", "-f"]
    let stringPipe = Pipe()
    if let data = output.data(using: .utf8) {
        stringPipe.fileHandleForWriting.write(data)
    }
    open.standardInput = stringPipe
    open.launch()

    exit(0)
} else {
    let semlog = SemanticLog(with: changes)
    print("\(semlog.output)")
}
