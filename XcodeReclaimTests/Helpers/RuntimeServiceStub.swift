import Foundation
import XcodeReclaimEngine

struct RuntimeServiceStub: RuntimeService, Sendable {
    let eachTaking: [Int]

    func runtimes() throws -> [Runtime] {
        eachTaking.map {
            Runtime(
                identifier: "9A65D489-798D-4E19-8CBC-FA5C9A1F2A1E",
                name: "iOS 26.2",
                build: "23C54",
                simulatorRuntime: "iOS 26.2",
                lastUsed: firstOfOctober,
                bytes: $0)
        }
    }

    func delete(runtimeWithIdentifier identifier: String) throws {}

    private var firstOfOctober: Date {
        (try? Date("2026-10-01T12:17:46Z", strategy: .iso8601)) ?? .distantPast
    }
}
