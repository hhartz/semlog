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

let semlog = SemanticLog(with: changes)
print(semlog.output)
