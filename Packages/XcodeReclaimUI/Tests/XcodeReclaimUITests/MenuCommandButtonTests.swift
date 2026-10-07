import AppKit
import SwiftUI
import Testing
import XcodeReclaimUI

@MainActor
struct MenuCommandButtonTests {
    @Test
    func pressingItsShortcut_performsTheCommand() {
        var performed = 0
        let sut = makeSUT(MenuCommand(title: "Refresh", shortcut: KeyboardShortcut("r"), isOffered: true, perform: { performed += 1 }))

        let handled = press("r", in: sut)

        #expect(handled)
        #expect(performed == 1)
    }

    @Test
    func pressingItsShortcut_performsNothingWhenTheCommandIsNotOffered() {
        var performed = 0
        let sut = makeSUT(MenuCommand(title: "Refresh", shortcut: KeyboardShortcut("r"), isOffered: false, perform: { performed += 1 }))

        let handled = press("r", in: sut)

        #expect(!handled)
        #expect(performed == 0)
    }

    @Test
    func draws_theCommandsTitle() {
        MenuCommandButton(MenuCommand(title: "Refresh", shortcut: KeyboardShortcut("r"), isOffered: true, perform: {}))
            .verify(named: "MENU_COMMAND_BUTTON", configuration: .window(size: Self.buttonSized))
    }
}

private extension MenuCommandButtonTests {
    static let buttonWidth: CGFloat = 160
    static let buttonHeight: CGFloat = 40
    static let buttonSized = CGSize(width: buttonWidth, height: buttonHeight)

    func makeSUT(_ command: MenuCommand) -> NSWindow {
        let shown = NSHostingView(rootView: MenuCommandButton(command))
        shown.frame = CGRect(origin: .zero, size: Self.buttonSized)
        let window = NSWindow(contentRect: shown.frame, styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView = shown
        shown.layoutSubtreeIfNeeded()
        settle()
        return window
    }

    func press(_ key: String, in window: NSWindow) -> Bool {
        let keyCodeOfR: UInt16 = 15
        guard
            let commandAndKey = NSEvent.keyEvent(
                with: .keyDown, location: .zero, modifierFlags: .command, timestamp: 0, windowNumber: window.windowNumber, context: nil,
                characters: key, charactersIgnoringModifiers: key, isARepeat: false, keyCode: keyCodeOfR)
        else { return false }

        let handled = window.performKeyEquivalent(with: commandAndKey)
        settle()
        return handled
    }

    func settle() {
        let turnsBeforeTheButtonIsDrawn = 50

        for _ in 0..<turnsBeforeTheButtonIsDrawn {
            RunLoop.current.run(mode: .default, before: .distantPast)
        }
    }
}
