import Foundation

struct WorldFailure: LocalizedError {
    let sentence: String

    var errorDescription: String? { sentence }
}
