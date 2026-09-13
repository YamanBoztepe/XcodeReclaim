import SwiftUI
import XcodeReclaimPresentation

public struct LeftoverListView: View {
    public let model: LeftoverListViewModel

    public init(model: LeftoverListViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            ScrollView { measuredLeftovers }
                .frame(minHeight: Room.theShortestList, idealHeight: Room.theListAsItOpens, maxHeight: .infinity)
        }
        .frame(minWidth: Room.theNarrowestWindow)
        .onAppear(perform: model.open)
        .alert(
            model.confirmation?.name ?? "",
            isPresented: Binding(get: { model.confirmation != nil }, set: { shown in if !shown { model.backOut() } })
        ) {
            Button("Delete", role: .destructive, action: model.confirm)
            Button("Cancel", role: .cancel, action: model.backOut)
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

private extension LeftoverListView {
    var header: some View {
        VStack(alignment: .leading, spacing: Room.betweenHeaderLines) {
            HStack(alignment: .firstTextBaseline) {
                Text(model.roomToReclaim.map { "\($0) to reclaim" } ?? "XcodeReclaim")
                    .font(.largeTitle.weight(.semibold))
                Spacer()
                Button("Refresh", systemImage: "arrow.clockwise", action: model.refresh)
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
                ForEach(model.sections) { section in
                    colour(of: section)
                        .frame(width: max(space.size.width * section.share - Room.betweenBarSegments, 0))
                }
            }
        }
        .frame(height: Room.theBarsHeight)
        .clipShape(.rect(cornerRadius: Room.theBarsCorner))
    }

    var key: some View {
        HStack(spacing: Room.betweenKeys) {
            ForEach(model.sections) { section in
                HStack(spacing: Room.besideASymbol) {
                    Circle().fill(colour(of: section)).frame(width: Room.aKeysDot, height: Room.aKeysDot)
                    Text(section.name).font(.callout)
                    Text(section.size).font(.callout).foregroundStyle(.secondary)
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
            Text(row.isBeingDeleted ? "Deleting…" : row.size)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            Button("Delete") { model.askAboutDeleting(row) }
                .disabled(!row.canBeDeleted)
        }
        .padding(.vertical, Room.aroundARow)
    }

    func colour(of section: LeftoverSection) -> Color {
        let colours: [Color] = [.accentColor, .teal, .orange]
        let place = model.sections.firstIndex(of: section) ?? 0
        return colours[place % colours.count]
    }
}
