@MainActor
final class MainThreadDecorator<Message> {
    private let decoratee: (Message) -> Void

    init(_ decoratee: @escaping (Message) -> Void) {
        self.decoratee = decoratee
    }

    nonisolated func callAsFunction(_ message: sending Message) {
        Task { @MainActor [self] in hand(message) }
    }

    nonisolated func answer(from work: @escaping @Sendable () -> sending Message) {
        Task.detached(priority: .userInitiated) { [self] in
            await hand(work())
        }
    }

    nonisolated func answer<Given>(from work: @escaping @Sendable (Given) -> sending Message, given: sending Given) {
        Task.detached(priority: .userInitiated) { [self] in
            await hand(work(given))
        }
    }

    private func hand(_ message: sending Message) {
        decoratee(message)
    }
}
