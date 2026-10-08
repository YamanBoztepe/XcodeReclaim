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

    @Test("A screen with a deletion under way says so above the list, marks the row and offers no other deletion")
    func draws_theScreenWithADeletionUnderWay() {
        makeSUT(
            showing: LeftoverListUIModel(
                title: "Deleting…",
                isMeasuring: false,
                deletionUnderWay: "Deleting Derived data…",
                sections: [cachesWithADeletionUnderWay])
        )
        .verify(named: "LEFTOVER_LIST_WITH_A_DELETION_UNDER_WAY")
    }

    @Test
    func draws_theScreenMeasuringAgainWhileADeletionIsUnderWay() {
        makeSUT(
            showing: LeftoverListUIModel(
                title: "Measuring…",
                isMeasuring: true,
                deletionUnderWay: "Deleting Derived data…")
        )
        .verify(named: "LEFTOVER_LIST_MEASURING_WHILE_A_DELETION_IS_UNDER_WAY")
    }

    @Test("A screen after a deletion says what came back")
    func draws_theScreenAfterADeletion() {
        makeSUT(
            showing: LeftoverListUIModel(
                title: "119.4 GB to reclaim",
                isMeasuring: false,
                deletionMessage: "28.4 GB came back.",
                sections: [caches])
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
    func draws_theKeyOfSixSectionsInColumns() {
        makeSUT(showing: LeftoverListUIModel(title: "188.8 GB to reclaim", isMeasuring: false, sections: sixKindsOfSection))
            .verify(named: "LEFTOVER_LIST_WITH_SIX_SECTIONS")
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

    var everyKindOfSection: [LeftoverSection] { [simulators, caches, xcodeVersions] }

    var sixKindsOfSection: [LeftoverSection] {
        let runtimesShare = 0.47
        let cachesShare = 0.30
        let simulatorsShare = 0.07
        let toolchainsShare = 0.06
        let archivesShare = 0.06
        let copiesShare = 0.04
        return [
            section(
                "Simulator runtimes", symbol: "square.stack.3d.up.fill", tint: .purple, share: runtimesShare,
                holding: row(named: "iOS 26.2 (23C54) — last used 1 Oct 2026", size: "88.9 GB")),
            section(
                "Caches and support files", symbol: "folder.fill", tint: .blue, share: cachesShare,
                holding: row(named: "Derived data", size: "56.4 GB")),
            section(
                "Simulators", symbol: "iphone", tint: .orange, share: simulatorsShare,
                holding: row(named: "iPhone 17 (iOS 26.4, 4D6D570A)", size: "12.8 GB")),
            section(
                "Swift toolchains", symbol: "swift", tint: .green, share: toolchainsShare,
                holding: row(named: "Swift 6.2.4 Release 2026-02-24 (a)", size: "11.6 GB")),
            section(
                "Archives", symbol: "archivebox.fill", tint: .pink, share: archivesShare,
                holding: row(named: "Communite Test 2.0.0 (697) — 24 Sep 2026", size: "11.2 GB")),
            section(
                "Xcode versions", symbol: "hammer.fill", tint: .teal, share: copiesShare,
                holding: row(named: "Xcode 27.1 (27A9268) — Desktop", size: "7.9 GB")),
        ]
    }

    func section(_ name: String, symbol: String, tint: LeftoverSection.Tint, share: Double, holding only: LeftoverRow) -> LeftoverSection {
        LeftoverSection(id: name, name: name, symbol: symbol, tint: tint, size: only.size, share: share, rows: [only])
    }

    var simulators: LeftoverSection {
        let shareOfTheRoom = 0.54
        return LeftoverSection(
            id: "Simulators",
            name: "Simulators",
            symbol: "iphone",
            tint: .orange,
            size: "79.8 GB",
            share: shareOfTheRoom,
            rows: [
                row(named: "iPhone 17 Pro (iOS 26.4, 21B507D3)", size: "7.8 GB", refusal: "The simulator is running.", canBeDeleted: false),
                row(named: "iPhone 16 Pro (iOS 18.1, 8FB6EB6C)", size: "4.1 GB"),
            ])
    }

    var caches: LeftoverSection {
        let shareOfTheRoom = 0.38
        return LeftoverSection(
            id: "Caches and support files",
            name: "Caches and support files",
            symbol: "folder.fill",
            tint: .blue,
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
            tint: .teal,
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
            tint: .blue,
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
