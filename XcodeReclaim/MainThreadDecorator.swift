@MainActor
final class MainThreadDecorator<Value: Sendable> {
    private let decoratee: (Value) -> Void

    init(_ decoratee: @escaping (Value) -> Void) {
        self.decoratee = decoratee
    }

    nonisolated func handle(_ value: Value) {
        Task { @MainActor [self] in decoratee(value) }
    }
}
