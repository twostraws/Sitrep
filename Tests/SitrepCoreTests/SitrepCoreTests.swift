@testable import SitrepCore
import XCTest
import class Foundation.Bundle
#if canImport(SwiftSyntax)
import SwiftSyntax
#endif
#if canImport(SwiftSyntaxParser)
import SwiftSyntaxParser
#endif

final class SitrepCoreTests: XCTestCase {
    let testClass = "class ViewController: UIViewController { }"
    let testStruct = "struct ContentView: View { }"
    let testEnum = "enum Direction: CaseIterable { case north, south, east, west }"
    let testProtocol = "protocol Testing: Codable { }"
    let testExtension = "extension User: Codable { }"
    let testImports = "import Battlestar\nimport StarTrek\nimport StarWars"
    let badURL = URL(fileURLWithPath: "/Sitrep_ThisWillNeverWorkNuhUh")

    var inputs: URL {
        var result = URL(fileURLWithPath: #file)
        result.deleteLastPathComponent()
        result.appendPathComponent("Inputs")
        return result
    }

    func getInput(_ file: String) throws -> URL {
        inputs.appendingPathComponent(file)
    }

    func testClassDetection() throws {
        let file = try File(sourceCode: testClass)

        XCTAssertEqual(file.results.rootNode.types.count, 1)

        if let testObject = file.results.rootNode.types.first {
            XCTAssertEqual(testObject.type, .class)
            XCTAssertEqual(testObject.name, "ViewController")
            XCTAssertEqual(testObject.inheritance.first, "UIViewController")
            XCTAssertEqual(testObject.inheritance.count, 1)
        } else {
            XCTFail("Failed to read the test object.")
        }
    }

    func testStructDetection() throws {
        let file = try File(sourceCode: testStruct)

        XCTAssertEqual(file.results.rootNode.types.count, 1)

        if let testObject = file.results.rootNode.types.first {
            XCTAssertEqual(testObject.type, .struct)
            XCTAssertEqual(testObject.name, "ContentView")
            XCTAssertEqual(testObject.inheritance.first, "View")
            XCTAssertEqual(testObject.inheritance.count, 1)
        } else {
            XCTFail("Failed to read the test object.")
        }
    }

    func testEnumDetection() throws {
        let file = try File(sourceCode: testEnum)

        XCTAssertEqual(file.results.rootNode.types.count, 1)

        if let testObject = file.results.rootNode.types.first {
            XCTAssertEqual(testObject.type, .enum)
            XCTAssertEqual(testObject.name, "Direction")
            XCTAssertEqual(testObject.inheritance.first, "CaseIterable")
            XCTAssertEqual(testObject.inheritance.count, 1)
            XCTAssertEqual(testObject.cases.count, 4)
            XCTAssertEqual(testObject.cases.first, "north")
        } else {
            XCTFail("Failed to read the test object.")
        }
    }

    func testProtocolDetection() throws {
        let file = try File(sourceCode: testProtocol)

        XCTAssertEqual(file.results.rootNode.types.count, 1)

        if let testObject = file.results.rootNode.types.first {
            XCTAssertEqual(testObject.type, .protocol)
            XCTAssertEqual(testObject.name, "Testing")
            XCTAssertEqual(testObject.inheritance.first, "Codable")
            XCTAssertEqual(testObject.inheritance.count, 1)
        } else {
            XCTFail("Failed to read the test object.")
        }
    }

    func testExtensionDetection() throws {
        let file = try File(sourceCode: testExtension)

        XCTAssertEqual(file.results.rootNode.types.count, 1)

        if let testObject = file.results.rootNode.types.first {
            XCTAssertEqual(testObject.type, .extension)
            XCTAssertEqual(testObject.name, "User")
            XCTAssertEqual(testObject.inheritance.first, "Codable")
            XCTAssertEqual(testObject.inheritance.count, 1)
        } else {
            XCTFail("Failed to read the test object.")
        }
    }

    func testImportDetection() throws {
        let file = try File(sourceCode: testImports)
        XCTAssertEqual(file.results.imports.count, 3)
    }

    func testLineCounting() throws {
        let input = try getInput("nesting.swift")
        let file = try File(url: input)

        XCTAssertEqual(file.results.body.lines.count, 32)
        XCTAssertEqual(file.results.strippedBody.lines.count, 23)
    }

    func testFileScanning() throws {
        let app = Scan(rootURL: inputs)
        let files = app.detectFiles()

        XCTAssertEqual(files.count, 10)
    }

    func testBadFileScanning() throws {
        let app = Scan(rootURL: badURL)
        let files = app.detectFiles()
        XCTAssertEqual(files.count, 0)
    }

    func testBadFileParsing() throws {
        let app = Scan(rootURL: badURL)
        let parseResult = app.parse(files: [badURL])
        XCTAssertEqual(parseResult.successful.count, 0)
        XCTAssertEqual(parseResult.failures.count, 1)
    }

    func testFileCounts() throws {
        let app = Scan(rootURL: inputs)
        let (_, files, failures) = app.run(creatingReport: false)

        XCTAssertEqual(files.count, 10)
        XCTAssertEqual(failures.count, 0)
    }

    func testCollationTypeCounts() throws {
        let app = Scan(rootURL: inputs)
        let (results, _, _) = app.run(creatingReport: false)

        XCTAssertEqual(results.classes.count, 4)
        XCTAssertEqual(results.structs.count, 3)
        XCTAssertEqual(results.enums.count, 1)
        XCTAssertEqual(results.protocols.count, 4)
        XCTAssertEqual(results.extensions.count, 2)
    }

    func testCollationImports() throws {
        let app = Scan(rootURL: inputs)
        let (results, _, _) = app.run(creatingReport: false)

        XCTAssertEqual(results.imports.count(for: "UIKit"), 2)
        XCTAssertEqual(results.imports.count(for: "SwiftUI"), 3)
    }

    func testSpecificInheritances() throws {
        let app = Scan(rootURL: inputs)
        let (results, _, _) = app.run(creatingReport: false)

        XCTAssertEqual(results.uiKitViewControllerCount, 2)
        XCTAssertEqual(results.uiKitViewCount, 0)
        XCTAssertEqual(results.swiftUIViewCount, 1)
    }

    func testEncoding() throws {
        let input = try getInput("class.swift")
        let file = try File(url: input)
        let json = try file.debugPrint()
        XCTAssertEqual(json.count, 2113)
    }

    func testTextReportGeneration() throws {
        let app = Scan(rootURL: inputs)
        let detectedFiles = app.detectFiles()
        let (scannedFiles, failures) = app.parse(files: detectedFiles)
        let results = app.collate(scannedFiles)
        let report = app.createTextReport(for: results, files: scannedFiles, failures: failures)

        XCTAssertTrue(report.contains("SITREP"))
    }

    func testJSONReportGeneration() throws {
        let app = Scan(rootURL: inputs)
        let detectedFiles = app.detectFiles()
        let (scannedFiles, failures) = app.parse(files: detectedFiles)
        let results = app.collate(scannedFiles)
        let report = app.createJSONReport(for: results, files: scannedFiles, failures: failures)

        guard let data = report.data(using: .utf8) else {
            XCTFail("Could not convert report string to data.")
            return
        }
        _ = try JSONDecoder().decode(Report.self, from: data)
    }

    func testBodyStripperRemovedComments() throws {
        let parsedBody = try SyntaxParser.parse(getInput("spacing.swift"))
        let strippedBody = BodyStripper().visit(parsedBody)
        let sourceLines = "\(strippedBody)".removingDuplicateLineBreaks()
        XCTAssertEqual(sourceLines.lines.count, 7)
    }

    func testCreatingReport() throws {
        let app = Scan(rootURL: inputs)
        let (_, files, failures) = app.run(creatingReport: true)

        XCTAssertEqual(files.count, 10)
        XCTAssertEqual(failures.count, 0)
    }

    func testLongestType() throws {
        let app = Scan(rootURL: inputs)
        let (results, _, _) = app.run(creatingReport: false)

        // Code in extensions should count towards the length of the type they're extending.
        // https://github.com/twostraws/Sitrep/issues/1
        XCTAssertEqual(results.longestType?.name, "Foobar")
        XCTAssertEqual(results.longestTypeLength, 45)
    }

    func testIgnoredFiles() {
        let app = Scan(rootURL: inputs)
        let config = Configuration(excluded: ["IgnoredDirectory"])
        let (_, files, _) = app.run(reportType: .json, configuration: config)

        XCTAssertEqual(files.count, 9, "There should be 9 files in all test inputs, because IgnoredDirectory should be excluded.")
    }

    static var allTests = [
        ("testClassDetection", testClassDetection),
        ("testStructDetection", testStructDetection),
        ("testEnumDetection", testEnumDetection),
        ("testProtocolDetection", testProtocolDetection),
        ("testExtensionDetection", testExtensionDetection),
        ("testImportDetection", testImportDetection),
        ("testLineCounting", testLineCounting),
        ("testFileScanning", testFileScanning),
        ("testBadFileScanning", testBadFileScanning),
        ("testBadFileParsing", testBadFileParsing),
        ("testFileCounts", testFileCounts),
        ("testCollationTypeCounts", testCollationTypeCounts),
        ("testCollationImports", testCollationImports),
        ("testCollationImports", testCollationImports),
        ("testSpecificInheritances", testSpecificInheritances),
        ("testEncoding", testEncoding),
        ("testTextReportGeneration", testTextReportGeneration),
        ("testJSONReportGeneration", testJSONReportGeneration),
        ("testBodyStripperRemovedComments", testBodyStripperRemovedComments),
        ("testCreatingReport", testCreatingReport),
        ("testLongestType", testLongestType),
        ("testIgnoredFiles", testIgnoredFiles)
    ]
}
