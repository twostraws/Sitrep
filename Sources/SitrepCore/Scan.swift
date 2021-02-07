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
import ArgumentParser

/// The main app struct, which figures out what to scan, performs the scan, collates the result, and displays it
public struct Scan {
    /// The URL that was scanned in this run
    let rootURL: URL

    public enum ReportType: String, ExpressibleByArgument, CaseIterable {
        /// simple text output
        case text
        /// formatted json output
        case json

        public init?(argument: String) {
            guard let format = Self(rawValue: argument) else { return nil }
            self = format
        }

        public static var args: String {
            let args = Self.allCases.map {
                $0.rawValue
            }.joined(separator: "|")

            return "[\(args)]"
        }
    }

    /// Creates an app instance from a URL to a project directory
    public init(rootURL: URL) {
        self.rootURL = rootURL
    }

    /// Performs the whole app run: scanning files, collating results, then optionally printing a report
    @discardableResult
    public func run(creatingReport: Bool = true,
                    reportType: ReportType = .text,
                    configuration: Configuration = Configuration.default) -> (results: Results, files: [URL], failures: [URL]) {
        let detectedFiles = detectFiles(excludedPath: configuration.excludedPath(path: rootURL.path))
        let (scannedFiles, failures) = parse(files: detectedFiles)
        let results = collate(scannedFiles)

        if creatingReport {
            switch reportType {
            case .text:
                let report = createTextReport(for: results, files: scannedFiles, failures: failures)
                print(report)
            case .json:
                let report = createJSONReport(for: results, files: scannedFiles, failures: failures)
                print(report)
            }
        }

        return (results, detectedFiles, failures)
    }

    public func detectFiles(excludedPath: [String] = []) -> [URL] {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(at: rootURL, includingPropertiesForKeys: nil)

        var detectedFiles = [URL]()

        while let objectURL = enumerator?.nextObject() as? URL {
            guard objectURL.hasDirectoryPath == false else { continue }

            let isExcluded = excludedPath.contains { path in
                objectURL.deletingLastPathComponent().relativePath.hasPrefix(path)
            }

            guard isExcluded == false else { continue }

            if objectURL.pathExtension == "swift" {
                detectedFiles.append(objectURL)
            }
        }

        return detectedFiles
    }

    public func parse(files: [URL]) -> (successful: [File], failures: [URL]) {
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

    public func collate(_ scannedFiles: [File]) -> Results {
        var results = Results(files: scannedFiles)

        var allTypesAndLength = [String: Int]()
        var allTypesByName = [String: Type]()

        for file in scannedFiles {
            // order all our types by what they are
            for item in file.results.rootNode.types {
                let name = item.name
                let typeLength = item.strippedBody.lines.count

                allTypesAndLength[name, default: 0] += typeLength
                allTypesByName[name] = item

                if item.type == .class {
                    results.classes.append(item)
                } else if item.type == .struct {
                    results.structs.append(item)
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

        // find the longest type and its length
        if let longestMatch = allTypesAndLength.max(by: { $0.value < $1.value }) {
            results.longestTypeLength = longestMatch.value
            results.longestType = allTypesByName[longestMatch.key]!
        }

        return results
    }

    /// Creates a report object from the scan results
    public func createReport(for results: Results, files: [File], failures: [URL]) -> Report {
        let imports = results.imports
            .allObjects
            .sorted { first, second in results.imports.count(for: first) > results.imports.count(for: second) }
            .compactMap { value -> Report.Stat? in
                guard let name = value as? String else {
                    return nil
                }
                
                return .init(name: name, value: results.imports.count(for: name))
            }

        let inheritances = [
            Report.Stat(name: "UIViewController", value: results.uiKitViewControllerCount),
            Report.Stat(name: "UIView", value: results.uiKitViewCount),
            Report.Stat(name: "SwiftUI.View", value: results.swiftUIViewCount)
        ]

        var longestFileStat: Report.Stat?

        if let longestFile = results.longestFile?.url?.lastPathComponent {
            longestFileStat = .init(name: longestFile, value: results.longestFileLength)
        }

        var longestTypeStat: Report.Stat?

        if let longestType = results.longestType?.name {
            longestTypeStat = .init(name: longestType, value: results.longestTypeLength)
        }

        return .init(scanStats: .init(scannedFiles: files.count,
                                      totalLinesOfCode: results.totalLinesOfCode,
                                      totalStrippedLinesOfCode: results.totalStrippedLinesOfCode,
                                      longestFile: longestFileStat,
                                      longestType: longestTypeStat),
                     objects: .init(structs: results.structs.count,
                                    classes: results.classes.count,
                                    enums: results.enums.count,
                                    protocols: results.protocols.count,
                                    extensions: results.extensions.count),
                     imports: imports,
                     inheritances: inheritances)
    }

    /// Prints out the report for a set of files in a pretty printed JSON format
    func createJSONReport(for results: Results, files: [File], failures: [URL]) -> String {
        let report = self.createReport(for: results, files: files, failures: failures)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(report), let string = String(data: data, encoding: .utf8) else {
            return "[Error] Could not encode JSON data."
        }

        return string
    }

    /// Prints out the report for a set of files
    func createTextReport(for results: Results, files: [File], failures: [URL]) -> String {
        let report = self.createReport(for: results, files: files, failures: failures)

        var output = ["SITREP"]
        output.append("------")
        output.append("")
        output.append("Overview")
        output.append("   Files scanned: \(report.scanStats.scannedFiles)")
        output.append("   Structs: \(report.objects.structs)")
        output.append("   Classes: \(report.objects.classes)")
        output.append("   Enums: \(report.objects.enums)")
        output.append("   Protocols: \(report.objects.protocols)")
        output.append("   Extensions: \(report.objects.extensions)")

        output.append("")

        output.append("Sizes")
        output.append("   Total lines of code: \(report.scanStats.totalLinesOfCode)")
        output.append("   Source lines of code: \(report.scanStats.totalStrippedLinesOfCode)")

        if let longestFile = report.scanStats.longestFile {
            output.append("   Longest file: \(longestFile.name) (\(longestFile.value) source lines)")
        }

        if let longestType = report.scanStats.longestType {
            output.append("   Longest type: \(longestType.name) (\(longestType.value) source lines)")
        }

        let imports = report.imports.map { "\($0.name) (\($0.value))" }.joined(separator: ", ")

        output.append("")
        output.append("Structure")
        output.append("   Imports: \(imports)")
        output.append("   UIKit View Controllers: \(results.uiKitViewControllerCount)")
        output.append("   UIKit Views: \(results.uiKitViewCount)")
        output.append("   SwiftUI Views: \(results.swiftUIViewCount)")
        output.append("")

        return output.joined(separator: "\n")
    }
}
