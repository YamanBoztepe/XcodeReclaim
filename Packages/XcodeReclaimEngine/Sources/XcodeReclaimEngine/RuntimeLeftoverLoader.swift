import XcodeReclaimCore

struct RuntimeLeftoverLoader {
    let runtimeService: any RuntimeService
    let simulatorService: any SimulatorService

    func leftovers(announcing announce: (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        let inUse = runtimesOfRunningSimulators()

        return reported().map { runtime in
            let kind = Leftover.Kind.runtime(name: runtime.name, build: runtime.build, lastUsed: runtime.lastUsed)
            let place = Leftover.Place.runtime(runtime.identifier)
            announce(kind, place)

            return Leftover(kind: kind, bytes: runtime.bytes, place: place, refusal: inUse.contains(runtime.simulatorRuntime) ? .runtimeIsInUse : nil)
        }
    }

    private func reported() -> [Runtime] {
        (try? runtimeService.runtimes()) ?? []
    }

    private func runtimesOfRunningSimulators() -> Set<String> {
        Set(((try? simulatorService.simulators()) ?? []).filter { !$0.isShutDown }.map(\.runtime))
    }
}
