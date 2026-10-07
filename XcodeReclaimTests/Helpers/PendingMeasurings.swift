struct PendingMeasurings {
    private var finishedMeasurings: Set<Int> = []
    private var continuations: [Int: CheckedContinuation<Void, Never>] = [:]

    mutating func resume(_ continuation: CheckedContinuation<Void, Never>, whenFinished measuring: Int) {
        guard !finishedMeasurings.contains(measuring) else {
            continuation.resume()
            return
        }

        continuations[measuring] = continuation
    }

    mutating func finish(_ measurings: Set<Int>) {
        finishedMeasurings.formUnion(measurings)
        for measuring in measurings {
            continuations.removeValue(forKey: measuring)?.resume()
        }
    }
}
