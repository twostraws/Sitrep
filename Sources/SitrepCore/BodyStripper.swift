//
// BodyStripper.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation
import SwiftSyntax

/// Scans source code to remove comments and most whitespace.
class BodyStripper: SyntaxRewriter {
    /// This class only scans tokens, and this method strips content from both leading and trailing trivia.
    override func visit(_ token: TokenSyntax) -> Syntax {
        let leading = clean(trivia: token.leadingTrivia)
        let trailing = clean(trivia: token.trailingTrivia)
        return Syntax(token.withLeadingTrivia(leading).withTrailingTrivia(trailing))
    }

    /// This removes all comments plus tab and spaces, and also collapses line breaks
    func clean(trivia: Trivia) -> Trivia {
        var cleanedTrivia = [TriviaPiece]()

        for piece in trivia {
            switch piece {
            case .lineComment, .blockComment, .docLineComment, .docBlockComment:
                continue
            case .spaces:
                continue
            case .tabs:
                continue
            case .newlines:
                cleanedTrivia.append(TriviaPiece.newlines(1))
            default:
                cleanedTrivia.append(piece)
            }
        }

        return Trivia(pieces: cleanedTrivia)
    }
}
