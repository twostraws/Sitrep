//
// main.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation
import SitrepCore

let file: String

let flagPrefix = "--"
let input = CommandLine.arguments.dropFirst()
var arguments = input.filter { !$0.hasPrefix(flagPrefix) }
var flags = input.filter { $0.hasPrefix(flagPrefix) }.map { $0.dropFirst(flagPrefix.count) }

if arguments.isEmpty {
    file = FileManager.default.currentDirectoryPath
} else {
    file = arguments[0]
}

let url = URL(fileURLWithPath: file)
var app = Scan(rootURL: url)
app.run(reportType: flags.contains("json") ? .json : .text)
