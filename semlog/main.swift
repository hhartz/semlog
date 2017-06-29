#!/usr/bin/swift
//
//  main.swift
//  semlog
//
//  Created by Henrik Hartz on 29/06/2017.
//  Copyright © 2017 Henrik Hartz. All rights reserved.
//

import Foundation

var standardInput = FileHandle.standardInput
var inputData = FileHandle.standardInput.availableData
var changes = String.init(data: inputData, encoding: .utf8) ?? ""
var changeList = changes.components(separatedBy: "\n")
var categories = NSMutableDictionary()

if changes.characters.count == 0 {
    print("use with e.g. git log --pretty=format:\"%s\" 0.1.0-9.. | semlog")
}

extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
}

for change in changeList {
    let changeset = change.components(separatedBy: ":")
    if let category = changeset.first?.trimmed.lowercased().capitalized, category.characters.count > 0, let description = changeset.last?.trimmed {
        if var categoryList = categories.value(forKey: category) as? [String] {
            categoryList.append(description)
            categories.setValue(categoryList, forKey: category)
        } else {
            categories.setValue([description], forKey: category)
        }
    }
}

for category in categories {
    print("\(category.key):")
    if let descriptions = category.value as? [String] {
        for description in descriptions {
            print("  - \(description)")
        }
    }
    print("\n")
}
