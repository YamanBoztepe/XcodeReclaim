public protocol SimulatorService {
    func simulators() throws -> [Simulator]
    func delete(simulatorWithIdentifier identifier: String) throws
}
