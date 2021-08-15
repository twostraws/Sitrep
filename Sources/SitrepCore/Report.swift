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
public struct Report: Codable {

    /// A named statistical value
    public struct Stat: Codable {
        /// Name of the statistic
        public var name: String
        /// Value of the statistic
        public var value: Int
    }

    /// Scan related statistics
    public struct Scan: Codable {
        /// Number of scanned files
        public var scannedFiles: Int
        /// Total lines of code
        public var totalLinesOfCode: Int
        /// Total stripped lines of code
        public var totalStrippedLinesOfCode: Int
        /// Longest file name and length
        public var longestFile: Stat?
        /// Longest type name and length 
        public var longestType: Stat?
    }

    /// Object related statistics
    public struct Object: Codable {
        /// Number of structs
        public var structs: Int
        /// Number of classes
        public var classes: Int
        /// Number of enums
        public var enums: Int
        /// Number of protocols
        public var protocols: Int
        /// Number of extensions
        public var extensions: Int
    }

    /// Scan statistics
    public var scanStats: Scan
    /// Object statistics
    public var objects: Object
    /// Import statistics
    public var imports: [Stat]
    /// Inheritance statistics
    public var inheritances: [Stat]
}
