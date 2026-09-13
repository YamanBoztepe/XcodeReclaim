import Foundation
import Observation
import XcodeReclaimCore

@Observable
public final class LeftoverListViewModel {
    public struct Confirmation: Equatable {
        public let name: String
        public let sentence: String

        public init(name: String, sentence: String) {
            self.name = name
            self.sentence = sentence
        }
    }

    public private(set) var isMeasuring = true
    public private(set) var leftoverBeingMeasured: String?
    public private(set) var sections: [LeftoverSection] = []
    public private(set) var roomToReclaim: String?
    public private(set) var confirmation: Confirmation?
    public private(set) var whatTheDeletionSaid: String?

    public var nothingToDelete: Bool { !isMeasuring && sections.isEmpty }

    private var leftovers: [Leftover] = []
    private var beingConfirmed: Leftover?
    private var beingDeleted: Leftover?
    private let measure: () -> Void
    private let delete: (Leftover) -> Void

    public init(measure: @escaping () -> Void, delete: @escaping (Leftover) -> Void) {
        self.measure = measure
        self.delete = delete
    }

    public func open() {
        measure()
    }

    public func announced(_ name: String) {
        leftoverBeingMeasured = name
    }

    public func measuringEnded(with measured: [Leftover]) {
        leftovers = measured
        isMeasuring = false
        leftoverBeingMeasured = nil
        redraw()
    }

    public func refresh() {
        isMeasuring = true
        leftoverBeingMeasured = nil
        leftovers = []
        whatTheDeletionSaid = nil
        redraw()
        measure()
    }

    public func askAboutDeleting(_ row: LeftoverRow) {
        guard let leftover = leftovers.first(where: { identity(of: $0.place) == row.id }), leftover.refusal == nil else { return }

        beingConfirmed = leftover
        confirmation = Confirmation(name: leftover.name, sentence: whatConfirmingCosts(leftover))
    }

    public func backOut() {
        beingConfirmed = nil
        confirmation = nil
    }

    public func confirm() {
        guard let leftover = beingConfirmed else { return }

        beingConfirmed = nil
        confirmation = nil
        beingDeleted = leftover
        whatTheDeletionSaid = nil
        redraw()
        delete(leftover)
    }

    public func deletionEnded(with deletion: Deletion) {
        guard let deleted = beingDeleted else { return }

        beingDeleted = nil
        whatTheDeletionSaid = whatItSaid(deletion, about: deleted)

        if case .freed = deletion {
            leftovers.removeAll { $0 == deleted }
        }
        redraw()
    }
}

private enum Kind: CaseIterable {
    case folder
    case simulator
    case xcodeCopy

    var name: String {
        switch self {
        case .folder: "Caches and support files"
        case .simulator: "Simulators"
        case .xcodeCopy: "Xcode versions"
        }
    }

    var symbol: String {
        switch self {
        case .folder: "folder.fill"
        case .simulator: "iphone"
        case .xcodeCopy: "hammer.fill"
        }
    }
}

private extension LeftoverListViewModel {
    func redraw() {
        let shown = Kind.allCases
            .map { kind in (kind: kind, held: leftovers.filter { self.kind(of: $0.place) == kind }) }
            .filter { !$0.held.isEmpty }
            .sorted { roomIn($0.held) > roomIn($1.held) }

        let marked = whatHoldsTheMostRoom(in: shown.flatMap(\.held))
        let roomOnTheScreen = roomIn(leftovers)

        sections = shown.map { section in
            LeftoverSection(
                id: section.kind.name,
                name: section.kind.name,
                symbol: section.kind.symbol,
                size: roomWritten(roomIn(section.held)),
                share: Double(roomIn(section.held)) / Double(roomOnTheScreen),
                rows: section.held.map { row(for: $0, marked: marked) })
        }
        roomToReclaim = leftovers.isEmpty ? nil : roomWritten(shown.reduce(0) { $0 + roomRounded(roomIn($1.held)) })
    }

    func roomIn(_ held: [Leftover]) -> Int {
        held.reduce(0) { $0 + $1.bytes }
    }

    func whatHoldsTheMostRoom(in shown: [Leftover]) -> Leftover? {
        guard shown.count > 1, let mostRoom = shown.map(\.bytes).max() else { return nil }

        return shown.first { $0.bytes == mostRoom }
    }

    func row(for leftover: Leftover, marked: Leftover?) -> LeftoverRow {
        LeftoverRow(
            id: identity(of: leftover.place),
            name: leftover.name,
            size: roomWritten(leftover.bytes),
            refusal: leftover.refusal.map(whyItCannotBeDeleted),
            holdsTheMostRoom: leftover == marked,
            isBeingDeleted: leftover == beingDeleted,
            canBeDeleted: leftover.refusal == nil && beingDeleted == nil)
    }

    func kind(of place: Leftover.Place) -> Kind {
        switch place {
        case .folder: .folder
        case .simulator: .simulator
        case .xcodeCopy: .xcodeCopy
        }
    }

    func identity(of place: Leftover.Place) -> String {
        switch place {
        case .folder(let url), .xcodeCopy(let url): url.path(percentEncoded: false)
        case .simulator(let identifier): identifier
        }
    }

    func whyItCannotBeDeleted(_ refusal: Leftover.Refusal) -> String {
        switch refusal {
        case .theSimulatorIsRunning: "The simulator is running."
        case .xcodeIsOpen: "Xcode is open."
        case .theCommandLineToolsPointAtIt: "The command line tools point at this one."
        }
    }

    func whatConfirmingCosts(_ leftover: Leftover) -> String {
        let frees = "Frees \(roomWritten(leftover.bytes))."
        guard let cost = leftover.cost else { return "\(frees) This cannot be undone." }

        return "\(frees) \(asASentence(cost)) This cannot be undone."
    }

    func whatItSaid(_ deletion: Deletion, about deleted: Leftover) -> String {
        switch deletion {
        case .freed(let bytes): "\(roomWritten(bytes)) came back."
        case .refused(let refusal): whyItCannotBeDeleted(refusal)
        case .failed(let why): "\(deleted.name) could not be deleted. \(why)"
        }
    }

    func asASentence(_ cost: String) -> String {
        cost.prefix(1).uppercased() + cost.dropFirst() + "."
    }
}
