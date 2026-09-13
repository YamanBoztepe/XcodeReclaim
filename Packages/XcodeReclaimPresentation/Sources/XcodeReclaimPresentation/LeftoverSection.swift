public struct LeftoverSection: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let symbol: String
    public let size: String
    public let share: Double
    public let rows: [LeftoverRow]

    public init(id: String, name: String, symbol: String, size: String, share: Double, rows: [LeftoverRow]) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.size = size
        self.share = share
        self.rows = rows
    }
}
