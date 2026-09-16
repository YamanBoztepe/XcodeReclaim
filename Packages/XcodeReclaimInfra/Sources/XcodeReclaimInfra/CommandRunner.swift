import Foundation

public protocol CommandRunner {
    func run(executable: URL, arguments: [String]) throws -> String
}
