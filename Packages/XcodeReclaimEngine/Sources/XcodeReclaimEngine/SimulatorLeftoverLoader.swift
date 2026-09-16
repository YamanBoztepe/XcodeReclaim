import XcodeReclaimCore

struct SimulatorLeftoverLoader {
    let simulatorService: any SimulatorService

    func leftovers(announcing announce: (String) -> Void) -> [Leftover] {
        let cost = "the apps inside it and their data are gone"

        return reported().map { simulator in
            let name = "\(simulator.name) (\(simulator.runtime), \(start(of: simulator.identifier)))"
            announce(name)

            return Leftover(
                name: name,
                bytes: simulator.bytes,
                place: .simulator(simulator.identifier),
                cost: cost,
                refusal: simulator.isShutDown ? nil : .simulatorIsRunning)
        }
    }

    private func reported() -> [Simulator] {
        (try? simulatorService.simulators()) ?? []
    }

    private func start(of identifier: String) -> String {
        String(identifier.prefix { $0 != "-" })
    }
}
