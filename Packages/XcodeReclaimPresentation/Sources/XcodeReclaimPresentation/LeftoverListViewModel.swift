import Foundation
import Observation
import XcodeReclaimCore

@Observable
public final class LeftoverListViewModel {
    public private(set) var uiModel = LeftoverListUIModel(title: appName, isMeasuring: true)

    private var leftovers: [Leftover] = []
    private var isMeasuring = true
    private var leftoverBeingMeasured: String?
    private var deletionMessage: String?
    private var confirmation: LeftoverListUIModel.Confirmation?
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
        redraw()
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
        deletionMessage = nil
        redraw()
        measure()
    }

    public func askAboutDeleting(_ row: LeftoverRow) {
        guard let leftover = leftovers.first(where: { identity(of: $0.place) == row.id }), leftover.refusal == nil else { return }

        beingConfirmed = leftover
        confirmation = LeftoverListUIModel.Confirmation(name: leftover.name, sentence: confirmationSentence(for: leftover))
        redraw()
    }

    public func backOut() {
        beingConfirmed = nil
        confirmation = nil
        redraw()
    }

    public func confirm() {
        guard let leftover = beingConfirmed else { return }

        beingConfirmed = nil
        confirmation = nil
        beingDeleted = leftover
        redraw()
        delete(leftover)
    }

    public func deletionEnded(with deletion: Deletion) {
        guard let deleted = beingDeleted else { return }

        beingDeleted = nil
        deletionMessage = deletionSentence(for: deletion, about: deleted)

        if case .freed = deletion {
            leftovers.removeAll { $0 == deleted }
        }
        redraw()
    }
}

private let appName = "XcodeReclaim"

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

        let marked = largest(in: shown.flatMap(\.held))
        let roomOnTheScreen = roomIn(leftovers)
        let tints = LeftoverSection.Tint.allCases
        let sections = shown.enumerated().map { place, section in
            LeftoverSection(
                id: section.kind.name,
                name: section.kind.name,
                symbol: section.kind.symbol,
                tint: tints[place % tints.count],
                size: Room.written(roomIn(section.held)),
                share: Double(roomIn(section.held)) / Double(roomOnTheScreen),
                rows: section.held.map { row(for: $0, marked: marked) })
        }

        uiModel = LeftoverListUIModel(
            title: title(over: shown.reduce(0) { $0 + Room.rounded(roomIn($1.held)) }),
            isMeasuring: isMeasuring,
            leftoverBeingMeasured: leftoverBeingMeasured,
            nothingToDelete: !isMeasuring && sections.isEmpty,
            deletionMessage: deletionMessage,
            sections: sections,
            confirmation: confirmation)
    }

    func title(over roomToReclaim: Int) -> String {
        guard !leftovers.isEmpty else { return appName }

        return "\(Room.written(roomToReclaim)) to reclaim"
    }

    func roomIn(_ held: [Leftover]) -> Int {
        held.reduce(0) { $0 + $1.bytes }
    }

    func largest(in shown: [Leftover]) -> Leftover? {
        guard shown.count > 1, let mostRoom = shown.map(\.bytes).max() else { return nil }

        return shown.first { $0.bytes == mostRoom }
    }

    func row(for leftover: Leftover, marked: Leftover?) -> LeftoverRow {
        LeftoverRow(
            id: identity(of: leftover.place),
            name: leftover.name,
            size: Room.written(leftover.bytes),
            refusal: leftover.refusal.map(refusalSentence(for:)),
            holdsTheMostRoom: leftover == marked,
            deletionUnderWay: leftover == beingDeleted ? "Deleting…" : nil,
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

    func refusalSentence(for refusal: Leftover.Refusal) -> String {
        switch refusal {
        case .simulatorIsRunning: "The simulator is running."
        case .xcodeIsOpen: "Xcode is open."
        case .commandLineToolsPointAtIt: "The command line tools point at this one."
        }
    }

    func confirmationSentence(for leftover: Leftover) -> String {
        let frees = "Frees \(Room.written(leftover.bytes))."
        guard let cost = leftover.cost else { return "\(frees) This cannot be undone." }

        return "\(frees) \(sentence(from: cost)) This cannot be undone."
    }

    func deletionSentence(for deletion: Deletion, about deleted: Leftover) -> String {
        switch deletion {
        case .freed(let bytes): "\(Room.written(bytes)) came back."
        case .refused(let refusal): refusalSentence(for: refusal)
        case .failed(let why): "\(deleted.name) could not be deleted. \(why)"
        }
    }

    func sentence(from cost: String) -> String {
        cost.prefix(1).uppercased() + cost.dropFirst() + "."
    }
}
