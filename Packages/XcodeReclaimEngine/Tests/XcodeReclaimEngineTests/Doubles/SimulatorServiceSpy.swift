import XcodeReclaimEngine

final class SimulatorServiceSpy: SimulatorService {
    enum Message: Hashable {
        case deleted(String)
    }

    private(set) var messages: [Message] = []

    var report: Result<[Simulator], any Error> = .success([])
    var deletion: Result<Void, any Error> = .success(())

    func simulators() throws -> [Simulator] {
        try report.get()
    }

    func delete(simulatorWithIdentifier identifier: String) throws {
        messages.append(.deleted(identifier))
        try deletion.get()
    }
}
