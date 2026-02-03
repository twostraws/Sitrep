//
// FileVisitor.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation
import SwiftSyntax

/// This does the main job of parsing a file into a structure we can analyze.
/// It organizes the code into a tree of nodes, with any top-level code
/// being placed into properties.
class FileVisitor: SyntaxVisitor {
    /// The top level of our tree, the file itself
    var rootNode = Node()

    /// All global comments from this file
    var comments = [Comment]()

    /// An array of the imports this file uses
    var imports = [String]()

    /// The raw code for this file
    var body = ""

    /// The code for this file, minus comments and whitespace
    var strippedBody = ""

    /// The node that is currently active, such as a class or  function.
    lazy var current: Node? = {
        rootNode
    }()

    /// Triggered on entering a class
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.class, from: node)
        return .visitChildren
    }

    /// Triggered on exiting a class; moves back up the tree
    override func visitPost(_ node: ClassDeclSyntax) {
        current = current?.parent
    }

    /// Triggered on entering an enum
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.enum, from: node)
        return .visitChildren
    }

    /// Triggered on exiting an enum; moves back up the tree
    override func visitPost(_ node: EnumDeclSyntax) {
        current = current?.parent
    }

    /// Triggered on exiting a single enum case
    override func visitPost(_ node: EnumCaseElementSyntax) {
        current?.cases.append(node.name.text)
    }

    /// Triggered on entering an extension
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.extension, from: node)
        return .visitChildren
    }

    /// Triggered on exiting an extension; moves back up the tree
    override func visitPost(_ node: ExtensionDeclSyntax) {
        current = current?.parent
    }

    /// Triggered on entering a function
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        var throwingStatus = Function.ThrowingStatus.unknown
        var isStatic = false
        var returnType = ""

        // Examine this function's modifiers to figure out whether it's static
        for modifier in node.modifiers {
            let modifierText = modifier.name.text

            if modifierText == "static" || modifierText == "class" {
                isStatic = true
            }
        }

        // Copy in the throwing status
        if let throwsSpecifier = node.signature.effectSpecifiers?.throwsClause?.throwsSpecifier {
            if let throwsOrRethrows = Function.ThrowingStatus(rawValue: throwsSpecifier.text) {
                throwingStatus = throwsOrRethrows
            }
        } else {
            throwingStatus = .none
        }

        let name = node.name.text

        // Flatten the list of parameters for easier storage
        let parameters = node.signature.parameterClause.parameters.map { $0.firstName.text }

        // If we have a return type, copy it here
        if let nodeReturnType = node.signature.returnClause?.type {
            returnType = "\(nodeReturnType)"
        }

        let newObject = Function(name: name, parameters: parameters, isStatic: isStatic, throwingStatus: throwingStatus, returnType: returnType)

        // Move one level deeper in our tree
        newObject.parent = current
        current?.functions.append(newObject)
        current = newObject

        return .visitChildren
    }

    /// Triggered on exiting a function; moves back up the tree
    override func visitPost(_ node: FunctionDeclSyntax) {
        current = current?.parent
    }

    /// Triggered on entering an identifer pattern – the part of a variable that contains its name
    override func visit(_ node: IdentifierPatternSyntax) -> SyntaxVisitorContinueKind {
        current?.variables.append(node.identifier.text)
        return .visitChildren
    }

    /// Triggered on finding an import statement
    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        let importName = node.path.description
        imports.append(importName)
        return .visitChildren
    }

    /// Triggered on entering a protocol
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.protocol, from: node)
        return .visitChildren
    }

    /// Triggered on exiting a protocol; moves back up the tree
    override func visitPost(_ node: ProtocolDeclSyntax) {
        current = current?.parent
    }

    /// Triggered on entering a file
    override func visit(_ node: SourceFileSyntax) -> SyntaxVisitorContinueKind {
        comments = comments(for: node._syntaxNode)
        body = "\(node)"
        strippedBody = body.removingDuplicateLineBreaks()
        return .visitChildren
    }

    /// Triggered on entering a struct
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        create(.struct, from: node)
        return .visitChildren
    }

    /// Triggered on exiting a struct; moves back up the tree
    override func visitPost(_ node: StructDeclSyntax) {
        current = current?.parent
    }

    /// Converts trivia to comments
    func extractComments(from trivia: TriviaPiece) -> Comment? {
        switch trivia {
        case .lineComment(let text), .blockComment(let text):
            return Comment(type: .regular, text: text)
        case .docLineComment(let text), .docBlockComment(let text):
            return Comment(type: .documentation, text: text)
        default:
            return nil
        }
    }

    /// Used for creating classes, structs, extensions, protocols, and structs
    func create(_ type: Type.ObjectType, from node: CommonSyntax) {
        let nodeBody = "\(node)"

        // THIS CODE IS DISABLED RIGHT NOW.
        // It was designed to put all type code through a syntax parser
        // so that we could accurately remove all comments.
        // However, this is slow – if this is to be re-enabled we need to
        // make it optional.
//        let nodeBodyStripped: String
//        do {
//            let parsedBody = try SyntaxParser.parse(source: nodeBody)
//            let strippedBody = BodyStripper().visit(parsedBody)
//            nodeBodyStripped = "\(strippedBody)"
//        } catch {
//            nodeBodyStripped = ""
//        }

        // Just use an empty string in place of the commented out code above.
        let nodeBodyStripped = ""

        let inheritanceClause = node.inheritanceClause?.inheritedTypes.map {
            "\($0.type)".trimmingCharacters(in: .whitespacesAndNewlines)
        } ?? []

        let name = node.commonName
            .trimmingCharacters(in: .whitespaces)

        let newObject = Type(type: type, name: name, inheritance: inheritanceClause, comments: comments(for: node._syntaxNode), body: nodeBody, strippedBody: nodeBodyStripped)

        newObject.parent = current
        current?.types.append(newObject)
        current = newObject
    }

    /// Reads all leading trivia for a node, discards everything that isn't a comment, then
    /// sends back an array of what's left.
    func comments(for node: Syntax) -> [Comment] {
        return node.leadingTrivia.compactMap(extractComments)
    }
}

/// The handful of common things we use across types
protocol CommonSyntax: SyntaxProtocol {
    var inheritanceClause: SwiftSyntax.InheritanceClauseSyntax? { get set }
    var commonName: String { get }
}

/// Returns the class's name text as its commonName
extension ClassDeclSyntax: CommonSyntax {
    var commonName: String { name.text }
}

/// Returns the enum's name text as its commonName
extension EnumDeclSyntax: CommonSyntax {
    var commonName: String { name.text }
}

/// Returns the struct's name text as its commonName
extension StructDeclSyntax: CommonSyntax {
    var commonName: String { name.text }
}

/// Returns the protocol's name text as its commonName
extension ProtocolDeclSyntax: CommonSyntax {
    var commonName: String { name.text }
}

/// Returns the extension's extended type as its commonName
extension ExtensionDeclSyntax: CommonSyntax {
    var commonName: String { "\(extendedType)" }
}
