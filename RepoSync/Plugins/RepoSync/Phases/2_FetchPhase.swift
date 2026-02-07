struct FetchPhase {
    let modules: [ModuleInfo]

    func run() {
        print("\n🛎️ Fetching:")
        BatchExecutor(data: modules) { module in
            print("\(module.name): Fetch...")
            let fetch = ProcessBuilder(git: module, ["fetch", "--tags", "--force"], options: .exitOnError).run()
            print("\(module.name): Fetched\n\(fetch.out)\n")
        }.run()
    }
}
