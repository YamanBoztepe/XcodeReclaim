public enum Deletion: Hashable, Sendable {
    case freed(Int)
    case refused(Leftover.Refusal)
    case failed(String)
}
