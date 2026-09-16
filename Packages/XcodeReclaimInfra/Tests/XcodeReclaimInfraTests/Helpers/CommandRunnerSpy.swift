import Foundation
import XcodeReclaimInfra

final class CommandRunnerSpy: CommandRunner {
    struct Run: Hashable {
        let executable: URL
        let arguments: [String]
    }

    private(set) var runs: [Run] = []

    var answers: [String: Result<String, any Error>] = [:]

    func run(executable: URL, arguments: [String]) throws -> String {
        runs.append(Run(executable: executable, arguments: arguments))
        return try answers[executable.lastPathComponent, default: .success("")].get()
    }
}
