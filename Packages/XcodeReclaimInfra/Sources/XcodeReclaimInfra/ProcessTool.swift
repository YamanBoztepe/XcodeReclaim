import Foundation

public struct ProcessTool: Tool {
    public init() {}

    public func run(executable: URL, arguments: [String]) throws -> String {
        let written = try emptyTemporaryFile()
        let said = try emptyTemporaryFile()
        defer {
            try? FileManager.default.removeItem(at: written)
            try? FileManager.default.removeItem(at: said)
        }

        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        process.standardOutput = try FileHandle(forWritingTo: written)
        process.standardError = try FileHandle(forWritingTo: said)
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw TheToolExitedWithAFailure(said: try text(of: said).trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return try text(of: written)
    }
}

struct TheToolExitedWithAFailure: LocalizedError {
    let said: String

    var errorDescription: String? { said }
}

private extension ProcessTool {
    func emptyTemporaryFile() throws -> URL {
        let file = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try Data().write(to: file)
        return file
    }

    func text(of file: URL) throws -> String {
        String(decoding: try Data(contentsOf: file), as: UTF8.self)
    }
}
