public struct LeftoverRow: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let size: String
    public let refusal: String?
    public let holdsTheMostRoom: Bool
    public let deletionUnderWay: String?
    public let canBeDeleted: Bool

    public init(id: String, name: String, size: String, refusal: String?, holdsTheMostRoom: Bool, deletionUnderWay: String?, canBeDeleted: Bool) {
        self.id = id
        self.name = name
        self.size = size
        self.refusal = refusal
        self.holdsTheMostRoom = holdsTheMostRoom
        self.deletionUnderWay = deletionUnderWay
        self.canBeDeleted = canBeDeleted
    }
}
