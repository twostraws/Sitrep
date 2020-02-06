//
// Type.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation

/// One data type from our code, with a very loose definition of "type"
class Type: Node {
    /// All the data we want to be able to write out for debugging purposes
    private enum CodingKeys: CodingKey {
        case name, type, inheritance, comments, body, strippedBody
    }

    /// The list of "types" we support
    enum ObjectType: String {
        case `class`, `enum`, `extension`, `protocol`, `struct`
    }

    /// The name of the type, eg `ViewController`
    let name: String

    /// The underlying type, e.g. class or struct
    let type: ObjectType

    /// The inheritance clauses attached to this type, including protocol conformances
    let inheritance: [String]

    /// An array of comments that describe this type
    let comments: [Comment]

    /// The raw source code for this type
    let body: String

    /// The source code for this type, minus empty lines and comments
    let strippedBody: String

    /// Creates an instance of Type
    init(type: ObjectType, name: String, inheritance: [String], comments: [Comment], body: String, strippedBody: String) {
        self.type = type
        self.name = name
        self.inheritance = inheritance
        self.comments = comments
        self.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        self.strippedBody = body.removingDuplicateLineBreaks()
    }

    /// Encodes the type, so we can produce debug output
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(inheritance, forKey: .inheritance)
        try container.encode(comments, forKey: .comments)
        try container.encode(body, forKey: .body)
        try container.encode(strippedBody, forKey: .strippedBody)
    }
}
