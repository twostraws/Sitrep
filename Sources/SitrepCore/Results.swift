//
// Results.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation

public struct Results {
    /// All the files detected by this scan
    var files: [File]

    /// All the classes detected across all files
    var classes = [Type]()

    /// All the structs detected across all files
    var structs = [Type]()

    /// All the enums detected across all files
    var enums = [Type]()

    /// All the protocols detected across all files
    var protocols = [Type]()

    /// All the extensions detected across all files
    var extensions = [Type]()

    /// All the imports detected across all files, stored with frequency
    var imports = NSCountedSet()

    /// A string containing all code in all files
    var totalCode = ""

    /// A string containing all stripped code in all files
    var totalStrippedCode = ""

    /// The number of lines in the longest file
    var longestFileLength = 0

    /// The File object storing the longest file that was scanned
    var longestFile: File?

    /// The nmber of lines in the longest type
    var longestTypeLength = 0

    /// The Type object storing the longest file that was scanned
    var longestType: Type?

    /// A count of how many functions were detected
    var functionCount = 0

    /// A count of how many functions were preceded by documentation comments
    var documentedFunctionCount = 0

    /// The total number of lines of code scanned across all files
    var totalLinesOfCode: Int {
        totalCode.lines.count
    }

    /// The total number of stripped lines of code scanned across all files
    var totalStrippedLinesOfCode: Int {
        totalStrippedCode.lines.count
    }
}
