import Foundation
import Yams

/// Holds the complete set of configured values and defaults.
public struct Configuration: Codable {
    private let excluded: [String]

    public static let `default`: Configuration = .init(
        excluded: []
    )

    public init(excluded: [String]) {
        self.excluded = excluded
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let excluded = try values.decode([String]?.self, forKey: .excluded)
        self.excluded = excluded ?? []
    }

    func excludedPath(path: String) -> [String] {
        excluded.map {
            "\(path)/\($0)"
        }
    }
}

extension Configuration {
    public static func parse(_ path: String) throws -> Configuration {
        let url = URL(fileURLWithPath: path)
        return try .parse(url)
    }

    public static func parse(_ url: URL) throws -> Configuration {
        let decoder = YAMLDecoder()
        let data = try String(contentsOf: url)
        return try decoder.decode(Self.self, from: data)
    }
}
