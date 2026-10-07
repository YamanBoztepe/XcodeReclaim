import XcodeReclaimEngine

final class RuntimeServiceSpy: RuntimeService {
    enum Message: Hashable {
        case deleted(String)
    }

    private(set) var messages: [Message] = []

    var report: Result<[Runtime], any Error> = .success([])
    var deletion: Result<Void, any Error> = .success(())

    func runtimes() throws -> [Runtime] {
        try report.get()
    }

    func delete(runtimeWithIdentifier identifier: String) throws {
        messages.append(.deleted(identifier))
        try deletion.get()
    }
}
