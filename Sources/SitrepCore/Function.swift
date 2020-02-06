//
// Function.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation

/// Represents one function or method in our parsed code.
class Function: Node {
    /// Stores whether the function is throwing or not
    enum ThrowingStatus: String {
        case none, `throws`, `rethrows`, unknown
    }

    /// The keys we need to write for debug output
    private enum CodingKeys: CodingKey {
        case name, parameters, isStatic, throwingStatus, returnType
    }

    /// The function name
    let name: String

    /// The parameter names received by the function
    let parameters: [String]

    /// Whether the function is static or not
    let isStatic: Bool

    /// Whether the function throws errors or not
    let throwingStatus: ThrowingStatus

    /// The data type returned by the function
    let returnType: String

    /// Creates an instance of Function using all its parameters
    init(name: String, parameters: [String], isStatic: Bool, throwingStatus: ThrowingStatus, returnType: String) {
        self.name = name
        self.parameters = parameters
        self.isStatic = isStatic
        self.throwingStatus = throwingStatus
        self.returnType = returnType
    }

    /// Encodes the function, so we can produce debug output
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(parameters, forKey: .parameters)
        try container.encode(isStatic, forKey: .isStatic)
        try container.encode(throwingStatus.rawValue, forKey: .throwingStatus)
        try container.encode(returnType, forKey: .returnType)
    }
}
