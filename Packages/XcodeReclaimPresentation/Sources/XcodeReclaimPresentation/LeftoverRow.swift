public struct LeftoverRow: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let size: String
    public let refusal: String?
    public let holdsTheMostRoom: Bool
    public let isBeingDeleted: Bool
    public let canBeDeleted: Bool

    public init(id: String, name: String, size: String, refusal: String?, holdsTheMostRoom: Bool, isBeingDeleted: Bool, canBeDeleted: Bool) {
        self.id = id
        self.name = name
        self.size = size
        self.refusal = refusal
        self.holdsTheMostRoom = holdsTheMostRoom
        self.isBeingDeleted = isBeingDeleted
        self.canBeDeleted = canBeDeleted
    }
}
