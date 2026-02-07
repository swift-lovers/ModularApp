import Foundation
import PackagePlugin

// MARK: - Options

/// Customizable options for RepoSync.
enum DefaultOptions {
    /// Set this flag to `false` to skip fetching from the remote.
    static let shouldFetch = true
    /// Set this flag to `true` to invoke `git reset --hard && git clean -fd` if local changes exist.
    static let shouldHardReset = false
    /// Set this flag to `false` to skip pull operation.
    static let shouldPull = true
    /// If true, skips repos with changes; if false, aborts when any repo is dirty.
    static let skipChangedInsteadOfAborting = true
    /// Default environment: "dev" or "prod".
    static let env = "dev"
    /// Pool size for batched operations.
    static let poolSize = 10
}

// MARK: - RepoSync

@main
struct RepoSync {
    func process(repoRoot: URL, arguments: [String]) throws {
        let start = Date()

        var parser = ArgumentExtractor(arguments)
        let env = parser.extractOption(named: "env").first ?? DefaultOptions.env
        if !["dev", "prod"].contains(env) {
            Diagnostics.error("Wrong environment: \(env)")
            return
        }

        FileManager.default.changeCurrentDirectoryPath(repoRoot.path())

        let config = try ConfigSupport.parse(repoRoot: repoRoot, env: env)

        // 1. Status Phase
        let unverifiedModules = getUnverifiedModules(config: config)
        let modules = StatusPhase(
            modules: unverifiedModules,
            shouldHardReset: DefaultOptions.shouldHardReset,
            skipChangedInsteadOfAborting: DefaultOptions.skipChangedInsteadOfAborting
        ).run()

        print("===========================================================================")

        // 2. Fetch Phase
        if DefaultOptions.shouldFetch {
            FetchPhase(modules: modules).run()
            print("===========================================================================")
        }

        // 3. Pull Phase
        if DefaultOptions.shouldPull {
            PullPhase(modules: modules).run()
        }

        let end = Date()
        let timeInterval = end.timeIntervalSince(start)
        print("\n✅ Done in \(String(format: "%.2f", timeInterval)) seconds.")
    }

    func getUnverifiedModules(config: [(String, String)]) -> [UnverifiedModuleInfo] {
        config.map { name, target in
            let status = Git.moduleFileSystemStatus(name: name)
            return UnverifiedModuleInfo(status: status, name: name, target: target)
        }
    }
}

// MARK: - SPM

extension RepoSync: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        var parser = ArgumentExtractor(arguments)
        if parser.extractFlag(named: "allow-writing-to-directory") == 0 {
            Diagnostics.error("Running this Plugin on an SPM Package via Xcode is not supported.")
            Diagnostics.error("Please use CLI variant.")
            exit(1)
        }

        try process(
            repoRoot: context.package.directoryURL.deletingLastPathComponent(),
            arguments: arguments
        )
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension RepoSync: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        try process(repoRoot: context.xcodeProject.directoryURL, arguments: arguments)
    }
}
#endif
