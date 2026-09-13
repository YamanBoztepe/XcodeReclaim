import Foundation

struct WhatTheWorldSaid: LocalizedError {
    let sentence: String

    var errorDescription: String? { sentence }
}
