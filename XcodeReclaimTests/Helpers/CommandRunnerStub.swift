import Foundation
import XcodeReclaimInfra

struct CommandRunnerStub: CommandRunner, Sendable {
    let answers: [String: String]

    func run(executable: URL, arguments: [String]) throws -> String {
        answers[executable.lastPathComponent, default: ""]
    }
}
