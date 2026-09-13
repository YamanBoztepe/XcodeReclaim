@MainActor
final class MainThreadDecorator<Message: Sendable> {
    private let decoratee: (Message) -> Void

    init(_ decoratee: @escaping (Message) -> Void) {
        self.decoratee = decoratee
    }

    nonisolated func callAsFunction(_ message: Message) {
        Task { @MainActor in decoratee(message) }
    }

    func answer(from work: @escaping @Sendable () -> Message) {
        Task.detached(priority: .userInitiated) { self(work()) }
    }
}
