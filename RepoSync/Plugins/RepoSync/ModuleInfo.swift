import Foundation

// MARK: - Unverified

enum ModuleFilesystemStatus {
    case doesNotExist
    case existsAndInvalid
    case existsAndValid
}

struct UnverifiedModuleInfo {
    let status: ModuleFilesystemStatus
    let name: String
    let target: String

    var asVerified: ModuleInfo {
        .init(name: name, target: target)
    }
}

// MARK: - Verified

struct ModuleInfo {
    let name: String
    let target: String
}
