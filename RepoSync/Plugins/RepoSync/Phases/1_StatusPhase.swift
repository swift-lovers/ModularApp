import Foundation
import PackagePlugin

struct StatusPhase {
    let modules: [UnverifiedModuleInfo]
    let shouldHardReset: Bool
    let skipChangedInsteadOfAborting: Bool

    func run() -> [ModuleInfo] {
        print("\n👀 STATUS:")
        var hasChanges = false
        var hasInvalid = false
        var verified: [ModuleInfo] = []

        for module in modules {
            switch module.status {
            case .doesNotExist:
                Diagnostics.warning("\(module.name): no folder. Will be cloned.")
                _ = ProcessBuilder(["git", "clone", Git.repo(named: module.name)]).run()
                _ = ProcessBuilder(git: module, ["symbolic-ref", "--short", "-q", "HEAD"]).run()
                verified.append(module.asVerified)
            case .existsAndInvalid:
                Diagnostics.error("\(module.name): invalid directory.")
                hasInvalid = true
            case .existsAndValid:
                let branch = ProcessBuilder(git: module, ["symbolic-ref", "--short", "-q", "HEAD"], options: []).run()
                let tag = ProcessBuilder(git: module, ["describe", "--tags", "--exact-match"], options: []).run()
                let rev = ProcessBuilder(git: module, ["rev-parse", "--short", "HEAD"], options: .exitOnError).run()
                let changes = ProcessBuilder(git: module, ["status", "--porcelain"], options: .exitOnError).run()

                if !changes.out.isEmpty {
                    Diagnostics.warning("\(module.name) | has local changes:\n\(changes.0)")
                    if shouldHardReset {
                        _ = ProcessBuilder(git: module, ["reset", "--hard"]).run()
                        _ = ProcessBuilder(git: module, ["clean", "-fd"]).run()
                    } else {
                        hasChanges = !skipChangedInsteadOfAborting
                        continue
                    }
                }

                let currentRev: String
                if branch.success {
                    currentRev = "[branch:\(branch.out)@\(rev.out)]"
                } else if tag.success {
                    currentRev = "[tag:\(tag.out)]"
                } else {
                    currentRev = "[rev:\(rev.out)]"
                }
                print("\(module.name) | current=\(currentRev), target=[\(module.target)] | no local changes")
                verified.append(module.asVerified)
            }
        }

        if hasChanges {
            Diagnostics.error("One or more modules have uncommitted changes. Please commit before proceeding.")
            exit(1)
        }

        if hasInvalid {
            Diagnostics.error("""
            One or more modules has incorrect folders which should be deleted.
            Delete them manually, or run with '--force' to delete automatically.
            """)
            exit(1)
        }

        return verified
    }
}
