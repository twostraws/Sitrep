//
//  Command.swift
//  ArgumentParser
//
//  Created by Yume on 2020/3/10.
//

import ArgumentParser
import Foundation
import SitrepCore

struct Command: ParsableCommand {
    @Option(name: [.short, .customLong("config")], help: "The path of `.sitrep.yml`.")
    var configurationPath: String?

    @Option(name: .shortAndLong, help: "The report format \(Scan.ReportType.args).")
    var format: Scan.ReportType = .text

    @Flag(name: [.customShort("i"), .customLong("info")], help: "Prints configuration information then exits.")
    var showInfo = false

    @Option(name: .shortAndLong, help: "The path of your project.")
    var path = FileManager.default.currentDirectoryPath

    func run() throws {
        let configurationPath = self.configurationPath ?? self.path + "/.sitrep.yml"
        let configuration: Configuration

        if FileManager.default.fileExists(atPath: configurationPath) {
            configuration = try Configuration.parse(configurationPath)
        } else {
            configuration = Configuration.default
        }

        if showInfo {
            print("""
                Configuration file: \(configurationPath)
                Active settings: \(configuration)
                Scan path: \(path)
                """)
        } else {
            let url = URL(fileURLWithPath: path)
            let app = Scan(rootURL: url)
            app.run(reportType: self.format, configuration: configuration)
        }
    }
}
