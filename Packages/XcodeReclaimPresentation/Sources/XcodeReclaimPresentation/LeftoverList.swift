import Foundation
import XcodeReclaimCore

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

struct LeftoverList {
    var held: [Leftover] = []
    var isMeasuring = true
    var beingMeasured: String?
    var deletionMessage: String?
    var confirmation: LeftoverListUIModel.Confirmation?
    var beingDeleted: Leftover?

    var uiModel: LeftoverListUIModel {
        let sections = sectionsInOrder()

        return LeftoverListUIModel(
            title: title(over: sections.reduce(0) { $0 + Room.rounded(roomIn($1.held)) }),
            isMeasuring: isMeasuring,
            leftoverBeingMeasured: beingMeasured,
            nothingToDelete: !isMeasuring && sections.isEmpty,
            deletionMessage: deletionMessage,
            sections: drawn(sections),
            confirmation: confirmation)
    }

    func leftover(shownAs id: String) -> Leftover? {
        held.first { identity(of: $0.place) == id }
    }

    func confirmationOver(_ leftover: Leftover) -> LeftoverListUIModel.Confirmation {
        LeftoverListUIModel.Confirmation(name: leftover.name, sentence: confirmationSentence(for: leftover))
    }

    func deletionSentence(for deletion: Deletion, about deleted: Leftover) -> String {
        switch deletion {
        case .freed(let bytes): "\(Room.written(bytes)) came back."
        case .refused(let refusal): refusalSentence(for: refusal)
        case .failed(let why): "\(deleted.name) could not be deleted. \(why)"
        }
    }
}

private extension LeftoverList {
    typealias Section = (kind: Kind, held: [Leftover])

    func sectionsInOrder() -> [Section] {
        Kind.allCases
            .map { kind in (kind: kind, held: held.filter { self.kind(of: $0.place) == kind }) }
            .filter { !$0.held.isEmpty }
            .sorted { roomIn($0.held) > roomIn($1.held) }
    }

    func drawn(_ sections: [Section]) -> [LeftoverSection] {
        let marked = largest(in: sections.flatMap(\.held))
        let roomOnTheScreen = roomIn(held)
        let tints = LeftoverSection.Tint.allCases

        return sections.enumerated().map { place, section in
            LeftoverSection(
                id: section.kind.name,
                name: section.kind.name,
                symbol: section.kind.symbol,
                tint: tints[place % tints.count],
                size: Room.written(roomIn(section.held)),
                share: Double(roomIn(section.held)) / Double(roomOnTheScreen),
                rows: section.held.map { row(for: $0, marked: marked) })
        }
    }

    func title(over roomToReclaim: Int) -> String {
        guard !held.isEmpty else { return appName }

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

    func sentence(from cost: String) -> String {
        cost.prefix(1).uppercased() + cost.dropFirst() + "."
    }
}
