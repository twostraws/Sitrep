//
// Comment.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation

/// One comment, regular or documentation, from the code
struct Comment: Encodable {
    enum CommentType: String, Encodable {
        case regular, documentation
    }

    var type: CommentType
    var text: String
}
