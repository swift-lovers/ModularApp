import Foundation
import PackagePlugin

enum ConfigSupport {
    static func parse(repoRoot: URL, env: String) throws -> [(String, String)] {
        let configURL = repoRoot
            .appending(component: "Module-Config")
            .appending(component: env)
            .appendingPathExtension("config")
        return try parse(at: configURL)
    }

    /// Parses file at given path, returning array of pairs with (ModuleName, BranchName)
    static func parse(at path: URL) throws -> [(String, String)] {
        let contents = try String(contentsOf: path, encoding: .utf8)
        return contents
            .split(separator: "\n")
            .compactMap { line -> (String, String)? in
                let components = line.components(separatedBy: "=")
                guard components.count == 2 else { return nil }
                return (components[0], components[1])
            }
    }
}
