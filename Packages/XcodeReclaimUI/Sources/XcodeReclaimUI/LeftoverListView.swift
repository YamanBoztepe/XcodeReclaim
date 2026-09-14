import SwiftUI
import XcodeReclaimPresentation

public struct LeftoverListView: View {
    public let model: LeftoverListUIModel
    public let onAppear: () -> Void
    public let onRefresh: () -> Void
    public let onSelect: (Set<String>) -> Void
    public let onSort: (LeftoverListUIModel.Sorting) -> Void
    public let onAskAboutDeleting: (Set<String>) -> Void
    public let onConfirm: () -> Void
    public let onBackOut: () -> Void

    public init(
        model: LeftoverListUIModel,
        onAppear: @escaping () -> Void,
        onRefresh: @escaping () -> Void,
        onSelect: @escaping (Set<String>) -> Void,
        onSort: @escaping (LeftoverListUIModel.Sorting) -> Void,
        onAskAboutDeleting: @escaping (Set<String>) -> Void,
        onConfirm: @escaping () -> Void,
        onBackOut: @escaping () -> Void
    ) {
        self.model = model
        self.onAppear = onAppear
        self.onRefresh = onRefresh
        self.onSelect = onSelect
        self.onSort = onSort
        self.onAskAboutDeleting = onAskAboutDeleting
        self.onConfirm = onConfirm
        self.onBackOut = onBackOut
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if model.saysAnythingAboveTheList {
                header
                Divider()
            }
            list
                .frame(minHeight: Layout.shortestList, idealHeight: Layout.listAsItOpens, maxHeight: .infinity)
        }
        .frame(minWidth: Layout.narrowestWindow)
        .navigationTitle(model.title)
        .toolbar { commands }
        .onAppear(perform: onAppear)
        .alert(
            model.confirmation?.question ?? "",
            isPresented: Binding(get: { model.confirmation != nil }, set: { shown in if !shown { onBackOut() } })
        ) {
            Button("Delete", action: onConfirm)
            Button("Cancel", role: .cancel, action: onBackOut)
        } message: {
            Text(model.confirmation?.sentence ?? "")
        }
    }
}

private enum Layout {
    static let narrowestWindow: CGFloat = 460
    static let shortestList: CGFloat = 120
    static let listAsItOpens: CGFloat = 360
    static let underSpinner: CGFloat = 12
    static let narrowestSizeColumn: CGFloat = 90
    static let sizeColumnAsItOpens: CGFloat = 110
    static let aroundEdges: CGFloat = 20
    static let betweenHeaderLines: CGFloat = 12
    static let betweenKeys: CGFloat = 20
    static let underKey: CGFloat = 6
    static let besideSymbol: CGFloat = 6
    static let underRowName: CGFloat = 2
    static let underMeasuringSentence: CGFloat = 4
    static let aroundRow: CGFloat = 4
    static let barHeight: CGFloat = 14
    static let barCorner: CGFloat = 7
    static let betweenBarSegments: CGFloat = 2
    static let keyDot: CGFloat = 8
    static let insideBadge: CGFloat = 6
    static let aroundBadge: CGFloat = 2
}

private extension LeftoverListUIModel {
    var saysAnythingAboveTheList: Bool { !sections.isEmpty || deletionMessage != nil }
}

private extension LeftoverSection.Tint {
    var colour: Color {
        switch self {
        case .accent: .accentColor
        case .teal: .teal
        case .orange: .orange
        }
    }
}

private extension LeftoverListView {
    @ToolbarContentBuilder var commands: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Delete Immediately", systemImage: "trash") { onAskAboutDeleting(model.selection) }
                .disabled(!model.canDeleteSelection)
            Button("Refresh", systemImage: "arrow.clockwise", action: onRefresh)
                .disabled(model.isMeasuring)
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: Layout.betweenHeaderLines) {
            if !model.sections.isEmpty {
                capacityBar
                legend
            }

            if let message = model.deletionMessage {
                Text(message).font(.callout).foregroundStyle(.secondary)
            }
        }
        .padding(Layout.aroundEdges)
    }

    var capacityBar: some View {
        GeometryReader { space in
            HStack(spacing: Layout.betweenBarSegments) {
                ForEach(model.sections) { section in
                    section.tint.colour
                        .frame(width: max(space.size.width * section.share - Layout.betweenBarSegments, 0))
                }
            }
        }
        .frame(height: Layout.barHeight)
        .clipShape(.rect(cornerRadius: Layout.barCorner))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("The room each kind holds")
        .accessibilityValue(model.sections.map { "\($0.name) \($0.size)" }.joined(separator: ", "))
    }

    var legend: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Layout.betweenKeys) {
                keys
                Spacer()
            }
            VStack(alignment: .leading, spacing: Layout.underKey) {
                keys
            }
        }
    }

    @ViewBuilder var keys: some View {
        ForEach(model.sections) { section in
            HStack(spacing: Layout.besideSymbol) {
                Circle()
                    .fill(section.tint.colour)
                    .frame(width: Layout.keyDot, height: Layout.keyDot)
                Text(section.name).font(.callout)
                Text(section.size).font(.callout).foregroundStyle(.secondary)
            }
            .fixedSize()
            .accessibilityElement(children: .combine)
        }
    }

    @ViewBuilder var list: some View {
        if model.isMeasuring {
            measuring
        } else if model.nothingToDelete {
            ContentUnavailableView("Nothing to delete", systemImage: "checkmark.circle")
        } else {
            measuredLeftovers
        }
    }

    var measuring: some View {
        VStack(spacing: Layout.underSpinner) {
            ProgressView()
            VStack(spacing: Layout.underMeasuringSentence) {
                Text("Measuring what Xcode left…").font(.callout)
                if let name = model.leftoverBeingMeasured {
                    Text(name).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var measuredLeftovers: some View {
        Table(of: LeftoverRow.self, selection: chosenRows, sortOrder: sortedColumn) {
            TableColumn("Name", value: \.name) { row in
                nameOf(row)
            }
            TableColumn("Size", value: \.size) { row in
                sizeOf(row)
            }
            .width(min: Layout.narrowestSizeColumn, ideal: Layout.sizeColumnAsItOpens)
        } rows: {
            ForEach(model.sections) { section in
                Section {
                    ForEach(section.rows) { row in
                        TableRow(row)
                    }
                } header: {
                    Label(section.name, systemImage: section.symbol)
                }
            }
        }
        .alternatingRowBackgrounds()
        .contextMenu(forSelectionType: LeftoverRow.ID.self) { rows in
            Button("Delete Immediately…") { onAskAboutDeleting(rows) }
        }
    }

    func nameOf(_ row: LeftoverRow) -> some View {
        VStack(alignment: .leading, spacing: Layout.underRowName) {
            HStack(spacing: Layout.besideSymbol) {
                Text(row.name)
                if row.holdsTheMostRoom {
                    Text("Holds the most room")
                        .font(.caption2)
                        .padding(.horizontal, Layout.insideBadge)
                        .padding(.vertical, Layout.aroundBadge)
                        .background(.tint, in: .capsule)
                        .foregroundStyle(.white)
                }
            }
            if let refusal = row.refusal {
                Text(refusal).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, Layout.aroundRow)
    }

    func sizeOf(_ row: LeftoverRow) -> some View {
        HStack {
            Spacer()
            Text(row.deletionUnderWay ?? row.size)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    var chosenRows: Binding<Set<LeftoverRow.ID>> {
        Binding(get: { model.selection }, set: { chosen in onSelect(chosen) })
    }

    var sortedColumn: Binding<[KeyPathComparator<LeftoverRow>]> {
        Binding(
            get: { [comparator(over: model.sorting)] },
            set: { clicked in onSort(sorting(from: clicked)) })
    }

    func comparator(over sorting: LeftoverListUIModel.Sorting) -> KeyPathComparator<LeftoverRow> {
        let order: SortOrder = sorting.ascending ? .forward : .reverse

        switch sorting.column {
        case .name: return KeyPathComparator(\LeftoverRow.name, order: order)
        case .size: return KeyPathComparator(\LeftoverRow.size, order: order)
        }
    }

    func sorting(from clicked: [KeyPathComparator<LeftoverRow>]) -> LeftoverListUIModel.Sorting {
        guard let column = clicked.first else { return .biggestFirst }

        return LeftoverListUIModel.Sorting(
            column: column.keyPath == \LeftoverRow.name ? .name : .size,
            ascending: column.order == .forward)
    }
}
