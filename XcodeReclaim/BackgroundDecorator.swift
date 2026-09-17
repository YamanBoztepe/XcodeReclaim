struct BackgroundDecorator<Value: Sendable> {
    private let decoratee: @Sendable () async -> Value

    init(_ decoratee: @escaping @Sendable () async -> Value) {
        self.decoratee = decoratee
    }

    func handle(then handleValue: @escaping @Sendable (Value) -> Void) {
        Task.detached(priority: .userInitiated) { [decoratee] in handleValue(await decoratee()) }
    }
}
