public struct LeftoverSection: Equatable, Identifiable {
    public enum Tint: Equatable, CaseIterable {
        case accent
        case teal
        case orange
    }

    public let id: String
    public let name: String
    public let symbol: String
    public let tint: Tint
    public let size: String
    public let share: Double
    public let rows: [LeftoverRow]

    public init(id: String, name: String, symbol: String, tint: Tint, size: String, share: Double, rows: [LeftoverRow]) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.tint = tint
        self.size = size
        self.share = share
        self.rows = rows
    }
}
