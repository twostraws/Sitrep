//
// Scan.swift
// Part of Sitrep, a tool for analyzing Swift projects.
//
// Copyright (c) 2020 Hacking with Swift
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE for license information
//

import Foundation

/// The main app struct, which figures out what to scan, performs the scan, collates the result, and displays it
public struct Scan {
    /// The URL that was scanned in this run
    let rootURL: URL

    /// Creates an app instance from a URL to a project directory
    public init(rootURL: URL) {
        self.rootURL = rootURL
    }

    /// Performs the whole app run: scanning files, collating results, then optionally printing a report
    @discardableResult
    public func run(creatingReport: Bool = true) -> (results: Results, files: [URL], failures: [URL]) {
        let detectedFiles = detectFiles()
        let (scannedFiles, failures) = parse(files: detectedFiles)
        let results = collate(scannedFiles)

        if creatingReport {
            let report = createReport(for: results, files: scannedFiles, failures: failures)
            print(report)
        }

        return (results, detectedFiles, failures)
    }

    func detectFiles() -> [URL] {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(at: rootURL, includingPropertiesForKeys: nil)

        var detectedFiles = [URL]()

        while let objectURL = enumerator?.nextObject() as? URL {
            guard objectURL.hasDirectoryPath == false else { continue }

            if objectURL.pathExtension == "swift" {
                detectedFiles.append(objectURL)
            }
        }

        return detectedFiles
    }

    func parse(files: [URL]) -> (successful: [File], failures: [URL]) {
        var scannedFiles = [File]()
        var failures = [URL]()

        for file in files {
            if let file = try? File(url: file) {
                scannedFiles.append(file)
            } else {
                failures.append(file)
            }
        }

        return (scannedFiles, failures)
    }

    func collate(_ scannedFiles: [File]) -> Results {
        var results = Results(files: scannedFiles)

        for file in scannedFiles {
            // order all our types by what they are
            for item in file.results.rootNode.types {
                if item.type == .class {
                    results.classes.append(item)

                    let typeLength = item.strippedBody.lines.count

                    if typeLength > results.longestTypeLength {
                        results.longestTypeLength = typeLength
                        results.longestType = item
                    }
                } else if item.type == .struct {
                    results.structs.append(item)

                    let typeLength = item.strippedBody.lines.count

                    if typeLength > results.longestTypeLength {
                        results.longestTypeLength = typeLength
                        results.longestType = item
                    }
                } else if item.type == .enum {
                    results.enums.append(item)
                } else if item.type == .protocol {
                    results.protocols.append(item)
                } else if item.type == .extension {
                    results.extensions.append(item)
                }
            }

            // bring all imports together from all files
            results.imports.addObjects(from: file.results.imports)

            // keep track of the total code from all files
            results.totalCode += file.results.body
            results.totalStrippedCode += file.results.strippedBody

            // figure out the longest file
            let fileLength = file.results.strippedBody.lines.count

            if fileLength > results.longestFileLength {
                results.longestFile = file
                results.longestFileLength = fileLength
            }
        }

        return results
    }

    /// Prints out the report for a set of files
    func createReport(for results: Results, files: [File], failures: [URL]) -> String {
        var output = ["SITREP"]

        output.append("------")
        output.append("")
        output.append("Overview")
        output.append("   Files scanned: \(files.count)")
        output.append("   Structs: \(results.structs.count)")
        output.append("   Classes: \(results.classes.count)")
        output.append("   Enums: \(results.enums.count)")
        output.append("   Protocols: \(results.protocols.count)")
        output.append("   Extensions: \(results.extensions.count)")

        output.append("")

        output.append("Sizes")
        output.append("   Total lines of code: \(results.totalLinesOfCode)")
        output.append("   Source lines of code: \(results.totalStrippedLinesOfCode)")

        if let longestFile = results.longestFile?.url?.lastPathComponent {
            output.append("   Longest file: \(longestFile) (\(results.longestFileLength) source lines)")
        }

        if let longestType = results.longestType?.name {
            output.append("   Longest type: \(longestType) (\(results.longestTypeLength) source lines)")
        }

        output.append("")
        output.append("Structure")

        let sortedImports = results.imports.allObjects.sorted { first, second in results.imports.count(for: first) > results.imports.count(for: second) }
        let formattedImports = sortedImports.map { "\($0) (\(results.imports.count(for: $0)))" }
        output.append("   Imports: \(formattedImports.joined(separator: ", "))")

        output.append("   UIKit View Controllers: \(results.uiKitViewControllerCount)")
        output.append("   UIKit Views: \(results.uiKitViewCount)")
        output.append("   SwiftUI Views: \(results.swiftUIViewCount)")

        return output.joined(separator: "\n")
    }
}
