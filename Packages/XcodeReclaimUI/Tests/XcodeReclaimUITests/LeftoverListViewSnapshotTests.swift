import SwiftUI
import Testing
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
struct LeftoverListViewSnapshotTests {
    @Test("A screen that is measuring says so and names nothing")
    func draws_theScreenWhileItIsMeasuringAndNamesNothing() {
        makeSUT(showing: LeftoverListUIModel(title: "Measuring…", isMeasuring: true))
            .verify(named: "LEFTOVER_LIST_MEASURING")
    }

    @Test("A screen that is measuring names the leftover it is working on")
    func draws_theScreenWhileItIsMeasuringALeftover() {
        makeSUT(showing: LeftoverListUIModel(title: "Measuring…", isMeasuring: true, leftoverBeingMeasured: "Derived data"))
            .verify(named: "LEFTOVER_LIST_MEASURING_A_LEFTOVER")
    }

    @Test("A measured screen draws its bar, its key and its three sections")
    func draws_theScreenWithEverythingItFound() {
        makeSUT(showing: LeftoverListUIModel(title: "147.8 GB to reclaim", isMeasuring: false, sections: everyKindOfSection))
            .verify(named: "LEFTOVER_LIST_WITH_THREE_SECTIONS")
    }

    @Test("A screen with nothing to delete says so")
    func draws_theScreenWithNothingToDelete() {
        makeSUT(showing: LeftoverListUIModel(title: "", isMeasuring: false, nothingToDelete: true))
            .verify(named: "LEFTOVER_LIST_WITH_NOTHING_TO_DELETE")
    }

    @Test("A screen with a deletion under way marks the row and offers no other deletion")
    func draws_theScreenWithADeletionUnderWay() {
        makeSUT(showing: LeftoverListUIModel(title: "147.8 GB to reclaim", isMeasuring: false, sections: [cachesWithADeletionUnderWay]))
            .verify(named: "LEFTOVER_LIST_WITH_A_DELETION_UNDER_WAY")
    }

    @Test("A screen after a deletion says what came back")
    func draws_theScreenAfterADeletion() {
        makeSUT(
            showing: LeftoverListUIModel(
                title: "119.4 GB to reclaim",
                isMeasuring: false,
                deletionMessage: "28.4 GB came back.",
                sections: [caches(tinted: .accent)])
        )
        .verify(named: "LEFTOVER_LIST_AFTER_A_DELETION")
    }

    @Test
    func draws_theScreenWithTheRowsTheDeveloperChose() {
        makeSUT(
            showing: LeftoverListUIModel(
                title: "147.8 GB to reclaim",
                isMeasuring: false,
                sections: everyKindOfSection,
                selection: ["Derived data", "Interface builder cache"],
                canDeleteSelection: true)
        )
        .verify(named: "LEFTOVER_LIST_WITH_ROWS_CHOSEN")
    }

    @Test
    func draws_theScreenSqueezedToItsNarrowestWindow() {
        let narrowestWindow = CGSize(width: 460, height: 640)

        makeSUT(showing: LeftoverListUIModel(title: "147.8 GB to reclaim", isMeasuring: false, sections: everyKindOfSection))
            .verify(named: "LEFTOVER_LIST_IN_THE_NARROWEST_WINDOW", configuration: .window(size: narrowestWindow))
    }

    @Test
    func draws_theScreenSortedByName() {
        makeSUT(
            showing: LeftoverListUIModel(
                title: "147.8 GB to reclaim",
                isMeasuring: false,
                sections: everyKindOfSection,
                sorting: LeftoverListUIModel.Sorting(column: .name, isAscending: true))
        )
        .verify(named: "LEFTOVER_LIST_SORTED_BY_NAME")
    }

    @Test("A row that cannot be deleted says why under its name")
    func draws_theScreenWithARowThatCannotBeDeleted() {
        makeSUT(showing: LeftoverListUIModel(title: "87.5 GB to reclaim", isMeasuring: false, sections: [simulators]))
            .verify(named: "LEFTOVER_LIST_WITH_A_ROW_THAT_CANNOT_BE_DELETED")
    }
}

private extension LeftoverListViewSnapshotTests {
    func makeSUT(showing model: LeftoverListUIModel) -> LeftoverListView {
        LeftoverListView(
            model: model,
            onAppear: {},
            onRefresh: {},
            onSelect: { _ in },
            onSort: { _ in },
            onAskAboutDeleting: { _ in },
            onConfirm: {},
            onCancel: {})
    }

    var everyKindOfSection: [LeftoverSection] { [simulators, caches(tinted: .teal), xcodeVersions] }

    var simulators: LeftoverSection {
        let shareOfTheRoom = 0.54
        return LeftoverSection(
            id: "Simulators",
            name: "Simulators",
            symbol: "iphone",
            tint: .accent,
            size: "79.8 GB",
            share: shareOfTheRoom,
            rows: [
                row(named: "iPhone 17 Pro (iOS 26.4, 21B507D3)", size: "7.8 GB", refusal: "The simulator is running.", canBeDeleted: false),
                row(named: "iPhone 16 Pro (iOS 18.1, 8FB6EB6C)", size: "4.1 GB"),
            ])
    }

    func caches(tinted tint: LeftoverSection.Tint) -> LeftoverSection {
        let shareOfTheRoom = 0.38
        return LeftoverSection(
            id: "Caches and support files",
            name: "Caches and support files",
            symbol: "folder.fill",
            tint: tint,
            size: "68.0 GB",
            share: shareOfTheRoom,
            rows: [
                row(named: "Derived data", size: "27.7 GB", holdsTheMostRoom: true),
                row(named: "Device support (iOS 26.5.2)", size: "5.9 GB"),
                row(named: "Interface builder cache", size: "6.2 GB"),
            ])
    }

    var xcodeVersions: LeftoverSection {
        let shareOfTheRoom = 0.08
        return LeftoverSection(
            id: "Xcode versions",
            name: "Xcode versions",
            symbol: "hammer.fill",
            tint: .orange,
            size: "11.8 GB",
            share: shareOfTheRoom,
            rows: [
                row(named: "Xcode 26.4.1 (17E201) — Applications", size: "4.2 GB", refusal: "Xcode is open.", canBeDeleted: false),
                row(named: "Xcode 26.2 (17C51) — Applications", size: "3.9 GB"),
                row(named: "Xcode — Desktop", size: "3.7 GB"),
            ])
    }

    var cachesWithADeletionUnderWay: LeftoverSection {
        LeftoverSection(
            id: "Caches and support files",
            name: "Caches and support files",
            symbol: "folder.fill",
            tint: .accent,
            size: "68.0 GB",
            share: 1,
            rows: [
                row(named: "Derived data", size: "27.7 GB", holdsTheMostRoom: true, deletionUnderWay: "Deleting…", canBeDeleted: false),
                row(named: "Previews", size: "3.4 GB", canBeDeleted: false),
            ])
    }

    func row(
        named name: String,
        size: String,
        refusal: String? = nil,
        holdsTheMostRoom: Bool = false,
        deletionUnderWay: String? = nil,
        canBeDeleted: Bool = true
    ) -> LeftoverRow {
        LeftoverRow(
            id: name,
            name: name,
            size: size,
            refusal: refusal,
            holdsTheMostRoom: holdsTheMostRoom,
            deletionUnderWay: deletionUnderWay,
            canBeDeleted: canBeDeleted)
    }
}
