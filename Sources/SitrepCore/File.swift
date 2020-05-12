//
// File.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation
import SwiftSyntax

/// Represents one file in the source code input
struct File {
    /// The file URL this is scanning
    let url: URL?

    /// The active scanner that walks through the code
    var results: FileVisitor

    /// Creates an instance of the scanner from a file, then starts it walking through code
    init(url: URL) throws {
        self.url = url
        results = FileVisitor()
        
        let sourceFile = try SyntaxParser.parse(url)
        results.walk(sourceFile)
    }

    /// Creates an instance of the scanner from a string, then starts it walking through code
    init(sourceCode: String) throws {
        self.url = nil
        results = FileVisitor()

        let sourceFile = try SyntaxParser.parse(source: sourceCode)
        results.walk(sourceFile)
    }

    /// Writes this file's tree to a JSON string for testing
    func debugPrint() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(results.rootNode)
        let json = String(decoding: encoded, as: UTF8.self)
        return json
    }
}
