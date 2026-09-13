import Foundation

enum DeveloperFolder {
    static let root = URL(fileURLWithPath: "/developer")
    static let derivedData = root.appending(path: "Xcode/DerivedData")
    static let interfaceBuilderCache = root.appending(path: "Xcode/UserData/IB Support")
    static let previews = root.appending(path: "Xcode/UserData/Previews")
    static let documentationCache = root.appending(path: "Xcode/DocumentationCache")
    static let deviceSupport = root.appending(path: "Xcode/iOS DeviceSupport")

    static let everythingOffered = [derivedData, interfaceBuilderCache, previews, documentationCache]

    static func deviceSupportFolder(holding systemVersion: String) -> URL {
        deviceSupportFolder(named: "iPhone15,2 \(systemVersion) (22A1)")
    }

    static func deviceSupportFolder(named name: String) -> URL {
        deviceSupport.appending(path: name)
    }
}
