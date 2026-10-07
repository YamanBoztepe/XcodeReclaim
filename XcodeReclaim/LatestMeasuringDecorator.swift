import XcodeReclaimCore

final class LatestMeasuringDecorator {
    final class Ticket {}

    private let announcing: (Leftover.Kind, Leftover.Place) -> Void
    private let delivering: ([Leftover]) -> Void
    private var latestTicket: Ticket?

    init(
        announcing: @escaping (Leftover.Kind, Leftover.Place) -> Void,
        delivering: @escaping ([Leftover]) -> Void
    ) {
        self.announcing = announcing
        self.delivering = delivering
    }

    func beginMeasuring() -> Ticket {
        let ticket = Ticket()
        latestTicket = ticket
        return ticket
    }

    func announce(_ kind: Leftover.Kind, at place: Leftover.Place, from ticket: Ticket) {
        guard ticket === latestTicket else { return }

        announcing(kind, place)
    }

    func deliver(_ leftovers: [Leftover], from ticket: Ticket) {
        guard ticket === latestTicket else { return }

        delivering(leftovers)
    }
}
