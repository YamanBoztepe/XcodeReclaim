import Foundation

public protocol Tool {
    func run(executable: URL, arguments: [String]) throws -> String
}
