import Foundation
import PackagePlugin

enum Git {
    /// Change this to your GitHub organization or username.
    static let githubOwner = "Alesh14"

    static func repo(named name: String) -> String {
        "https://github.com/\(githubOwner)/\(name)"
    }

    static func moduleFileSystemStatus(name: String) -> ModuleFilesystemStatus {
        guard FileManager.default.fileExists(atPath: name) else {
            return .doesNotExist
        }

        guard FileManager.default.fileExists(atPath: [name, ".git"].joined(separator: "/")) else {
            return .existsAndInvalid
        }

        let remote = ProcessBuilder(git: name, ["remote", "get-url", "origin"], options: .exitOnError).run()
        guard let remoteURL = URL(string: remote.out), name == remoteURL.lastPathComponent else {
            return .existsAndInvalid
        }

        return .existsAndValid
    }
}
