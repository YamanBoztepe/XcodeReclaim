import Foundation

enum SnapshotPreferences {
    private static let blueAccentColour = 4
    private static let fontSmoothingOn = 2

    static func pin() {
        var arguments = UserDefaults.standard.volatileDomain(forName: UserDefaults.argumentDomain)
        arguments["AppleAccentColor"] = blueAccentColour
        arguments["AppleFontSmoothing"] = fontSmoothingOn
        UserDefaults.standard.setVolatileDomain(arguments, forName: UserDefaults.argumentDomain)
    }
}
