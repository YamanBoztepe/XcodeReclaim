import AppKit
import ObjectiveC

enum SnapshotDisplay {
    static let retinaScale: CGFloat = 2
    private static let fontSmoothingOn = 2

    static func pin() {
        var arguments = UserDefaults.standard.volatileDomain(forName: UserDefaults.argumentDomain)
        arguments["AppleFontSmoothing"] = fontSmoothingOn
        UserDefaults.standard.setVolatileDomain(arguments, forName: UserDefaults.argumentDomain)

        guard let screenScale = class_getInstanceMethod(NSScreen.self, #selector(getter: NSScreen.backingScaleFactor)) else { return }
        let retina: @convention(block) (NSScreen) -> CGFloat = { _ in retinaScale }
        method_setImplementation(screenScale, imp_implementationWithBlock(retina))
    }
}
