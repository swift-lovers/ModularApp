import Foundation

struct BatchExecutor<Element: Sendable> {
    let data: [Element]
    var action: @Sendable (Element) -> Void

    func run() {
        let taskPool = OperationQueue()
        taskPool.maxConcurrentOperationCount = DefaultOptions.poolSize

        for element in data {
            taskPool.addOperation {
                action(element)
            }
        }

        taskPool.waitUntilAllOperationsAreFinished()
    }
}
