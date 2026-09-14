public enum Deletion: Hashable, Sendable {
    case freed(Int)
    case partlyFreed(Int, stillThere: Int, why: String)
    case refused(Leftover.Refusal)
    case failed(String)
}
