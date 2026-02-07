import Foundation
import PackagePlugin

// MARK: - Command

typealias Command = [String]

// MARK: - ProcessBuilderOptions

struct ProcessBuilderOptions: OptionSet {
    let rawValue: Int

    static let exitOnError = ProcessBuilderOptions(rawValue: 1 << 0)
    static let flushOutput = ProcessBuilderOptions(rawValue: 1 << 1)

    static let `default`: Self = [.exitOnError, .flushOutput]
}

// MARK: - ProcessBuilder

struct ProcessBuilder {
    let command: Command
    let options: ProcessBuilderOptions

    init(_ command: Command, options: ProcessBuilderOptions = .default) {
        self.command = command
        self.options = options
    }

    func run() -> (out: String, success: Bool) {
        let command = command.joined(separator: " ")
        let task = Process()
        let pipe = Pipe()

        var env = ProcessInfo.processInfo.environment
        env["PATH"] = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        task.environment = env
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(filePath: "/bin/sh")
        task.standardInput = nil

        try! task.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(String(decoding: data, as: UTF8.self).dropLast())
        if options.contains(.flushOutput), !output.isEmpty {
            print(output)
        }

        task.waitUntilExit()

        if options.contains(.exitOnError), task.terminationStatus != 0 {
            Diagnostics.error("Command '\(command)' returned a non-zero exit code (\(task.terminationStatus)) with output:\n\(output)")
            exit(task.terminationStatus)
        }

        return (output, task.terminationStatus == 0)
    }
}

// MARK: Additional inits

extension ProcessBuilder {
    init(git child: UnverifiedModuleInfo, _ command: Command, options: ProcessBuilderOptions = .default) {
        self.command = ["git", "-C", child.name] + command
        self.options = options
    }

    init(git child: ModuleInfo, _ command: Command, options: ProcessBuilderOptions = .default) {
        self.command = ["git", "-C", child.name] + command
        self.options = options
    }

    init(git child: String, _ command: Command, options: ProcessBuilderOptions = .default) {
        self.command = ["git", "-C", child] + command
        self.options = options
    }
}
