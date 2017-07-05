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

if args.count > 1, args[1] == "--help" || args[1] == "-h" {
    usage()
    exit(0)
} else if args.count > 2, let file = args[2].components(separatedBy: "=").last {
    if let fileData = FileManager.default.contents(atPath: file),
        let fileString = String.init(data: fileData, encoding: .utf8) {
        changes = fileString
    } else {
        print("unable to open or read \"\(file)\"")
        exit(0)
    }
} else {
    while let inputData = readLine() {
        changes += "\(inputData)\n"
    }
}


let semlog = SemanticLog(with: changes)
print(semlog.output)
