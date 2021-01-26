//
// Report.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation

/// The root class for the JSON report
struct Report: Codable {

    /// A named statistical value
    struct Stat: Codable {
        /// Name of the statistic
        var name: String
        /// Value of the statistic
        var value: Int
    }

    /// Scan related statistics
    struct Scan: Codable {
        /// Number of scanned files
        var scannedFiles: Int
        /// Total lines of code
        var totalLinesOfCode: Int
        /// Total stripped lines of code
        var totalStrippedLinesOfCode: Int
        /// Longest file name and length
        var longestFile: Stat?
        /// Longest type name and length 
        var longestType: Stat?
    }

    /// Object related statistics
    struct Object: Codable {
        /// Number of structs
        var structs: Int
        /// Number of classes
        var classes: Int
        /// Number of enums
        var enums: Int
        /// Number of protocols
        var protocols: Int
        /// Number of extensions
        var extensions: Int
    }

    /// Scan statistics
    var scanStats: Scan
    /// Object statistics
    var objects: Object
    /// Import statistics
    var imports: [Stat]
    /// Inheritance statistics
    var inheritances: [Stat]
}
