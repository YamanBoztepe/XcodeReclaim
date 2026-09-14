import SwiftUI
import XcodeReclaimPresentation

public struct LeftoverListView: View {
    public let model: LeftoverListUIModel
    public let onAppear: () -> Void
    public let onRefresh: () -> Void
    public let onAskAboutDeleting: (LeftoverRow) -> Void
    public let onConfirm: () -> Void
    public let onBackOut: () -> Void

    public init(
        model: LeftoverListUIModel,
        onAppear: @escaping () -> Void,
        onRefresh: @escaping () -> Void,
        onAskAboutDeleting: @escaping (LeftoverRow) -> Void,
        onConfirm: @escaping () -> Void,
        onBackOut: @escaping () -> Void
    ) {
        self.model = model
        self.onAppear = onAppear
        self.onRefresh = onRefresh
        self.onAskAboutDeleting = onAskAboutDeleting
        self.onConfirm = onConfirm
        self.onBackOut = onBackOut
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            Group {
                if model.isMeasuring {
                    measuring
                } else {
                    ScrollView { measuredLeftovers }
                }
            }
            .frame(minHeight: Layout.shortestList, idealHeight: Layout.listAsItOpens, maxHeight: .infinity)
        }
        .frame(minWidth: Layout.narrowestWindow)
        .onAppear(perform: onAppear)
        .alert(
            model.confirmation?.name ?? "",
            isPresented: Binding(get: { model.confirmation != nil }, set: { shown in if !shown { onBackOut() } })
        ) {
            Button("Delete", role: .destructive, action: onConfirm)
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
    static let aroundEdges: CGFloat = 20
    static let betweenSections: CGFloat = 24
    static let betweenHeaderLines: CGFloat = 12
    static let betweenKeys: CGFloat = 20
    static let besideSymbol: CGFloat = 6
    static let besideRow: CGFloat = 12
    static let underRowName: CGFloat = 2
    static let underSpinner: CGFloat = 12
    static let underMeasuringSentence: CGFloat = 4
    static let aroundRow: CGFloat = 8
    static let barHeight: CGFloat = 14
    static let barCorner: CGFloat = 7
    static let betweenBarSegments: CGFloat = 2
    static let keyDot: CGFloat = 8
    static let insideBadge: CGFloat = 6
    static let aroundBadge: CGFloat = 2
    static let underSectionHeading: CGFloat = 8
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
    var header: some View {
        VStack(alignment: .leading, spacing: Layout.betweenHeaderLines) {
            HStack(alignment: .firstTextBaseline) {
                Text(model.title).font(.largeTitle.weight(.semibold))
                Spacer()
                Button("Refresh", systemImage: "arrow.clockwise", action: onRefresh)
                    .disabled(model.isMeasuring)
            }

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
    }

    var legend: some View {
        HStack(spacing: Layout.betweenKeys) {
            ForEach(model.sections) { section in
                HStack(spacing: Layout.besideSymbol) {
                    Circle()
                        .fill(section.tint.colour)
                        .frame(width: Layout.keyDot, height: Layout.keyDot)
                    Text(section.name).font(.callout)
                    Text(section.size).font(.callout).foregroundStyle(.secondary)
                }
            }
            Spacer()
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
        VStack(alignment: .leading, spacing: Layout.betweenSections) {
            if model.nothingToDelete {
                Text("Nothing to delete.").foregroundStyle(.secondary)
            }

            ForEach(model.sections) { section in
                VStack(alignment: .leading, spacing: 0) {
                    Label(section.name, systemImage: section.symbol)
                        .font(.headline)
                        .padding(.bottom, Layout.underSectionHeading)

                    ForEach(section.rows) { row in
                        rowView(row)
                        Divider()
                    }
                }
            }
        }
        .padding(Layout.aroundEdges)
    }

    func rowView(_ row: LeftoverRow) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Layout.besideRow) {
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
            Spacer()
            Text(row.deletionUnderWay ?? row.size)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            Button("Delete") { onAskAboutDeleting(row) }
                .disabled(!row.canBeDeleted)
        }
        .padding(.vertical, Layout.aroundRow)
    }
}
