struct PullPhase {
    let modules: [ModuleInfo]

    func run() {
        print("\n⬇️ Pulling:")
        BatchExecutor(data: modules) { module in
            let branch = ProcessBuilder(git: module, ["symbolic-ref", "--short", "-q", "HEAD"], options: []).run()
            if branch.success, branch.out == module.target {
                print("\(module.name): Pulling...")
                _ = ProcessBuilder(git: module, ["pull"]).run()
            } else {
                let isTag = !ProcessBuilder(git: module, ["tag", "-l", module.target]).run().out.isEmpty
                let isBranch = !ProcessBuilder(git: module, ["branch", "-l", module.target]).run().out.isEmpty

                if isTag {
                    print("\(module.name): Use tag, checkout...")
                    _ = ProcessBuilder(git: module, ["checkout", module.target]).run()
                } else if isBranch {
                    print("\(module.name): Use branch, checkout and pull...")
                    _ = ProcessBuilder(git: module, ["checkout", module.target]).run()
                    _ = ProcessBuilder(git: module, ["pull"]).run()
                } else {
                    print("\(module.name): Use commit, checkout...")
                    _ = ProcessBuilder(git: module, ["checkout", module.target]).run()
                }
            }
        }.run()
    }
}
