import XcodeReclaimEngine

struct SimulatorServiceStub: SimulatorService, Sendable {
    let eachTaking: [Int]

    func simulators() throws -> [Simulator] {
        eachTaking.map {
            Simulator(
                identifier: "21B507D3-909E-465B-957C-4B370278399F",
                name: "iPhone 17",
                runtime: "iOS 26.4",
                isShutDown: true,
                bytes: $0)
        }
    }

    func delete(simulatorWithIdentifier identifier: String) throws {}
}
