import Foundation
import XcodeReclaimCore

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
    var beingDeleted: [Leftover] = []
    var selected: Set<String> = []
    var sorting = LeftoverListUIModel.Sorting.biggestFirst

    var uiModel: LeftoverListUIModel {
        let sections = sectionsInOrder()

        return LeftoverListUIModel(
            title: title(over: sections.reduce(0) { $0 + roomShown(in: $1.held) }),
            isMeasuring: isMeasuring,
            leftoverBeingMeasured: beingMeasured,
            nothingToDelete: !isMeasuring && sections.isEmpty,
            deletionMessage: deletionMessage,
            sections: drawn(sections),
            selection: selected,
            sorting: sorting,
            canDeleteSelection: !offered(shownAs: selected).isEmpty && beingDeleted.isEmpty,
            confirmation: confirmation)
    }

    func leftovers(shownAs shown: Set<String>) -> [Leftover] {
        held.filter { shown.contains(identity(of: $0.place)) }
    }

    func offered(shownAs shown: Set<String>) -> [Leftover] {
        leftovers(shownAs: shown).filter { $0.refusal == nil }
    }

    mutating func drop(_ leftover: Leftover) {
        held.removeAll { $0 == leftover }
        selected.remove(identity(of: leftover.place))
    }

    mutating func resize(_ leftover: Leftover, to bytes: Int) {
        guard let row = held.firstIndex(of: leftover) else { return }

        held[row] = Leftover(
            name: leftover.name,
            bytes: bytes,
            place: leftover.place,
            cost: leftover.cost,
            refusal: leftover.refusal)
    }

    func confirmationOver(_ leftovers: [Leftover], keeping kept: Int) -> LeftoverListUIModel.Confirmation {
        LeftoverListUIModel.Confirmation(
            question: question(over: leftovers),
            sentence: confirmationSentence(for: leftovers, keeping: kept))
    }

    func refusalSentence(for refusal: Leftover.Refusal) -> String {
        switch refusal {
        case .simulatorIsRunning: "The simulator is running."
        case .xcodeIsOpen: "Xcode is open."
        case .commandLineToolsPointAtIt: "The command line tools point at this one."
        }
    }

    func failureSentence(about deleted: Leftover, why: String) -> String {
        "\(deleted.name) could not be deleted. \(why)"
    }

    func partialSentence(about deleted: Leftover, why: String) -> String {
        "\(deleted.name) was only partly deleted. \(why)"
    }

    func deletionSentence(over roomThatCameBack: Int, andWhatWentWrong wrong: [String]) -> String? {
        let said = (roomThatCameBack > 0 ? ["\(Room.written(roomThatCameBack)) came back."] : []) + wrong

        return said.isEmpty ? nil : said.joined(separator: " ")
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
        let roomOnTheScreen = roomShown(in: held)
        let tints = LeftoverSection.Tint.allCases

        return sections.enumerated().map { place, section in
            LeftoverSection(
                id: section.kind.name,
                name: section.kind.name,
                symbol: section.kind.symbol,
                tint: tints[place % tints.count],
                size: Room.written(roomShown(in: section.held)),
                share: Double(roomShown(in: section.held)) / Double(roomOnTheScreen),
                rows: sorted(section.held).map { row(for: $0, marked: marked) })
        }
    }

    func sorted(_ shown: [Leftover]) -> [Leftover] {
        shown
            .enumerated()
            .sorted { offered, other in
                switch reading(of: offered.element, against: other.element) {
                case .orderedSame: offered.offset < other.offset
                case .orderedAscending: sorting.ascending
                case .orderedDescending: !sorting.ascending
                }
            }
            .map(\.element)
    }

    func reading(of leftover: Leftover, against other: Leftover) -> ComparisonResult {
        switch sorting.column {
        case .name: leftover.name.localizedStandardCompare(other.name)
        case .size: reading(of: leftover.bytes, against: other.bytes)
        }
    }

    func reading(of room: Int, against other: Int) -> ComparisonResult {
        guard room != other else { return .orderedSame }

        return room < other ? .orderedAscending : .orderedDescending
    }

    func title(over roomToReclaim: Int) -> String {
        guard !isMeasuring else { return "Measuring…" }
        guard !held.isEmpty else { return "" }

        return "\(Room.written(roomToReclaim)) to reclaim"
    }

    func roomIn(_ held: [Leftover]) -> Int {
        held.reduce(0) { $0 + $1.bytes }
    }

    func roomShown(in held: [Leftover]) -> Int {
        held.reduce(0) { $0 + Room.rounded($1.bytes) }
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
            deletionUnderWay: beingDeleted.contains(leftover) ? "Deleting…" : nil,
            canBeDeleted: leftover.refusal == nil && beingDeleted.isEmpty)
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

    func question(over leftovers: [Leftover]) -> String {
        guard let only = leftovers.first, leftovers.count == 1 else { return "Delete \(leftovers.count) items?" }

        return "Delete \(only.name)?"
    }

    func confirmationSentence(for leftovers: [Leftover], keeping kept: Int) -> String {
        let frees = "Frees \(Room.written(roomIn(leftovers)))."
        let keeping = kept > 0 ? ["Leaving \(kept) that cannot be deleted."] : []

        return ([frees] + keeping + costs(of: leftovers) + ["This cannot be undone."]).joined(separator: " ")
    }

    func costs(of leftovers: [Leftover]) -> [String] {
        leftovers.compactMap(\.cost).reduce(into: [String]()) { said, cost in
            let sentence = self.sentence(from: cost)
            guard !said.contains(sentence) else { return }

            said.append(sentence)
        }
    }

    func sentence(from cost: String) -> String {
        cost.prefix(1).uppercased() + cost.dropFirst() + "."
    }
}
