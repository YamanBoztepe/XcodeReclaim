public enum Deletion: Hashable {
    case freed(Int)
    case refused(Leftover.Refusal)
    case failed(String)
}
