import Foundation

enum RuntimeList {
    struct Image {
        let identifier: String
        let runtimeIdentifier: String
        let version: String
        let build: String
        let sizeBytes: Int
        let lastUsedAt: String?

        init(
            identifier: String = "9A65D489-798D-4E19-8CBC-FA5C9A1F2A1E",
            runtimeIdentifier: String = "com.apple.CoreSimulator.SimRuntime.iOS-26-2",
            version: String = "26.2",
            build: String = "23C54",
            sizeBytes: Int = 10_407_690_816,
            lastUsedAt: String? = "2026-10-01T12:17:46Z"
        ) {
            self.identifier = identifier
            self.runtimeIdentifier = runtimeIdentifier
            self.version = version
            self.build = build
            self.sizeBytes = sizeBytes
            self.lastUsedAt = lastUsedAt
        }
    }

    static func reporting(_ images: [Image]) -> String {
        let written = Dictionary(
            uniqueKeysWithValues: images.map { image -> (String, [String: Any]) in
                var written: [String: Any] = [
                    "identifier": image.identifier,
                    "runtimeIdentifier": image.runtimeIdentifier,
                    "version": image.version,
                    "build": image.build,
                    "sizeBytes": image.sizeBytes,
                    "kind": "Patchable Cryptex Disk Image",
                    "state": "Ready",
                    "deletable": true,
                ]
                written["lastUsedAt"] = image.lastUsedAt
                return (image.identifier, written)
            })
        let data = (try? JSONSerialization.data(withJSONObject: written)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}
