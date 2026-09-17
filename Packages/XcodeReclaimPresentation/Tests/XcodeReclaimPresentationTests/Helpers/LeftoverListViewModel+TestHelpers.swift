import XcodeReclaimCore
import XcodeReclaimPresentation

extension LeftoverListViewModel {
    var shownRows: [LeftoverRow] { uiModel.sections.flatMap(\.rows) }
    var shownNames: [String] { shownRows.map(\.name) }
    var selectedNames: [String] { shownRows.filter { uiModel.selection.contains($0.id) }.map(\.name) }
    var namesBeingDeleted: [String] { shownRows.compactMap { $0.deletionUnderWay == nil ? nil : $0.name } }

    func announced(_ leftover: Leftover) {
        announced(leftover.kind, at: leftover.place)
    }

    func askAboutDeleting(_ rows: LeftoverRow...) {
        askAboutDeleting(Set(rows.map(\.id)))
    }

    func select(rowsNamed names: String...) {
        select(identities(of: names))
    }

    func askAboutDeleting(rowsNamed names: String...) {
        askAboutDeleting(identities(of: names))
    }

    private func identities(of names: [String]) -> Set<String> {
        Set(shownRows.filter { names.contains($0.name) }.map(\.id))
    }
}
