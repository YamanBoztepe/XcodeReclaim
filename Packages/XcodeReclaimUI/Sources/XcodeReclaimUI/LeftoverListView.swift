import SwiftUI
import XcodeReclaimPresentation

public struct LeftoverListView: View {
    private let model: LeftoverListUIModel
    private let onAppear: () -> Void
    private let onRefresh: () -> Void
    private let onAskAboutDeleting: (LeftoverRow) -> Void
    private let onConfirm: () -> Void
    private let onBackOut: () -> Void

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
            ScrollView { measuredLeftovers }
                .frame(minHeight: Room.theShortestList, idealHeight: Room.theListAsItOpens, maxHeight: .infinity)
        }
        .frame(minWidth: Room.theNarrowestWindow)
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

private enum Room {
    static let theNarrowestWindow: CGFloat = 460
    static let theShortestList: CGFloat = 120
    static let theListAsItOpens: CGFloat = 360
    static let aroundTheEdges: CGFloat = 20
    static let betweenSections: CGFloat = 24
    static let betweenHeaderLines: CGFloat = 12
    static let betweenKeys: CGFloat = 20
    static let besideASymbol: CGFloat = 6
    static let besideARow: CGFloat = 12
    static let underARowsName: CGFloat = 2
    static let aroundARow: CGFloat = 8
    static let theBarsHeight: CGFloat = 14
    static let theBarsCorner: CGFloat = 7
    static let betweenBarSegments: CGFloat = 2
    static let aKeysDot: CGFloat = 8
    static let insideABadge: CGFloat = 6
    static let aroundABadge: CGFloat = 2
    static let underASectionHeading: CGFloat = 8
}

private let theSectionColours: [Color] = [.accentColor, .teal, .orange]

private extension LeftoverListView {
    var sectionsInOrder: [(offset: Int, element: LeftoverSection)] {
        Array(model.sections.enumerated())
    }

    var header: some View {
        VStack(alignment: .leading, spacing: Room.betweenHeaderLines) {
            HStack(alignment: .firstTextBaseline) {
                Text(model.title).font(.largeTitle.weight(.semibold))
                Spacer()
                Button("Refresh", systemImage: "arrow.clockwise", action: onRefresh)
                    .disabled(model.isMeasuring)
            }

            if !model.sections.isEmpty {
                capacityBar
                key
            }

            if let said = model.whatTheDeletionSaid {
                Text(said).font(.callout).foregroundStyle(.secondary)
            }

            if model.isMeasuring {
                measuring
            }
        }
        .padding(Room.aroundTheEdges)
    }

    var capacityBar: some View {
        GeometryReader { space in
            HStack(spacing: Room.betweenBarSegments) {
                ForEach(sectionsInOrder, id: \.element.id) { section in
                    theSectionColours[section.offset % theSectionColours.count]
                        .frame(width: max(space.size.width * section.element.share - Room.betweenBarSegments, 0))
                }
            }
        }
        .frame(height: Room.theBarsHeight)
        .clipShape(.rect(cornerRadius: Room.theBarsCorner))
    }

    var key: some View {
        HStack(spacing: Room.betweenKeys) {
            ForEach(sectionsInOrder, id: \.element.id) { section in
                HStack(spacing: Room.besideASymbol) {
                    Circle()
                        .fill(theSectionColours[section.offset % theSectionColours.count])
                        .frame(width: Room.aKeysDot, height: Room.aKeysDot)
                    Text(section.element.name).font(.callout)
                    Text(section.element.size).font(.callout).foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }

    var measuring: some View {
        HStack(spacing: Room.aroundARow) {
            ProgressView().controlSize(.small)
            VStack(alignment: .leading, spacing: Room.underARowsName) {
                Text("Measuring what Xcode left…").font(.callout)
                if let being = model.leftoverBeingMeasured {
                    Text(being).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }

    var measuredLeftovers: some View {
        VStack(alignment: .leading, spacing: Room.betweenSections) {
            if model.nothingToDelete {
                Text("Nothing to delete.").foregroundStyle(.secondary)
            }

            ForEach(model.sections) { section in
                VStack(alignment: .leading, spacing: 0) {
                    Label(section.name, systemImage: section.symbol)
                        .font(.headline)
                        .padding(.bottom, Room.underASectionHeading)

                    ForEach(section.rows) { row in
                        drawn(row)
                        Divider()
                    }
                }
            }
        }
        .padding(Room.aroundTheEdges)
    }

    func drawn(_ row: LeftoverRow) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Room.besideARow) {
            VStack(alignment: .leading, spacing: Room.underARowsName) {
                HStack(spacing: Room.besideASymbol) {
                    Text(row.name)
                    if row.holdsTheMostRoom {
                        Text("Holds the most room")
                            .font(.caption2)
                            .padding(.horizontal, Room.insideABadge)
                            .padding(.vertical, Room.aroundABadge)
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
        .padding(.vertical, Room.aroundARow)
    }
}
