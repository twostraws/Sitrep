//
// Extensions.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation

extension Array {
    /// Counts how many items in an array match a predicate
    func sum(where predicate: (Element) throws -> Bool) rethrows -> Int {
        var total = 0

        for item in self {
            if try predicate(item) {
                total += 1
            }
        }

        return total
    }
}

extension String {
    /// An array of lines in this string, created by splitting on line breaks
    var lines: [String] {
        components(separatedBy: "\n")
    }

    /// BodyStripper removes all comments and most whitespace, but it doesn't collapse multiple
    /// repeating instances do line breaks. This method does that clean up work.
    func removingDuplicateLineBreaks() -> String {
        let strippedLines = self.lines
        let nonEmptyLines = strippedLines.filter { $0.isEmpty == false }
        return nonEmptyLines.joined(separator: "\n")
    }
}
