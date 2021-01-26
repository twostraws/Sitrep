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
    @Option(name: .shortAndLong, help: "The report format \(Scan.ReportType.args).")
    var format: Scan.ReportType = .text
    
    @Option(name: [.short, .customLong("config")], help: "The path of `.sitrep.yml`.")
    var configurationPath: String?
    
    @Option(name: .shortAndLong, help: "The path of your project.")
    var path = FileManager.default.currentDirectoryPath

    @Flag(name: .shortAndLong, help: "Print configuration settings then exit.")
    var showConfiguration = false
    
    func run() throws {
        let configurationPath = self.configurationPath ?? self.path + "/.sitrep.yml"
        let configuration: Configuration

        if FileManager.default.fileExists(atPath: configurationPath) {
            configuration = try Configuration.parse(configurationPath)
        } else {
            configuration = Configuration.default
        }

        if showConfiguration {
            print("""
                Using configuration: \(configurationPath)
                Configuration: \(configuration)
                Scan path: \(path)
                """)
        } else {
            let url = URL(fileURLWithPath: path)
            let app = Scan(rootURL: url)
            app.run(reportType: self.format, configuration: configuration)
        }
    }
}
