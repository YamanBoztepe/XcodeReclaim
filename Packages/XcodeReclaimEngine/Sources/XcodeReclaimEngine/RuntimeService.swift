public protocol RuntimeService {
    func runtimes() throws -> [Runtime]
    func delete(runtimeWithIdentifier identifier: String) throws
}
