import XcodeReclaimCore

struct SimulatorLeftoverLoader {
    let simulatorService: any SimulatorService

    func leftovers(announcing announce: (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        reported().map { simulator in
            let kind = Leftover.Kind.simulator(name: simulator.name, runtime: simulator.runtime)
            let place = Leftover.Place.simulator(simulator.identifier)
            announce(kind, place)

            return Leftover(kind: kind, bytes: simulator.bytes, place: place, refusal: simulator.isShutDown ? nil : .simulatorIsRunning)
        }
    }

    private func reported() -> [Simulator] {
        (try? simulatorService.simulators()) ?? []
    }
}
