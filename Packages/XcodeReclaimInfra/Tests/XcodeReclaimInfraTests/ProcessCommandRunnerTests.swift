import Foundation
import Testing
import XcodeReclaimInfra

struct ProcessCommandRunnerTests {
    @Test("A refusal carries what the tool said")
    func run_throwsWhatTheToolSaidWhenItExitsWithAFailure() {
        let sut = makeSUT()
        let refusing = aToolRefusingWith("Invalid device", exitingWith: 148)

        let received = #expect(throws: (any Error).self) { try sut.run(executable: refusing.executable, arguments: refusing.arguments) }

        #expect(received?.localizedDescription == "Invalid device")
    }

    @Test
    func run_answersWhatTheToolWrote() throws {
        let sut = makeSUT()
        let writing = aToolWriting("21B507D3-909E-465B-957C-4B370278399F")

        let received = try sut.run(executable: writing.executable, arguments: writing.arguments)

        #expect(received == "21B507D3-909E-465B-957C-4B370278399F\n")
    }

    @Test
    func run_throwsWhenTheToolWroteBeforeItFailed() {
        let sut = makeSUT()
        let refusing = aToolWritingThenRefusingWith("some of the devices", said: "Invalid device", exitingWith: 148)

        let received = #expect(throws: (any Error).self) { try sut.run(executable: refusing.executable, arguments: refusing.arguments) }

        #expect(received?.localizedDescription == "Invalid device")
    }

    @Test
    func run_throwsWhenTheToolIsNotThere() {
        let sut = makeSUT()

        #expect(throws: (any Error).self) {
            try sut.run(executable: URL(fileURLWithPath: "/usr/bin/no-such-tool"), arguments: [])
        }
    }
}

private extension ProcessCommandRunnerTests {
    func makeSUT() -> ProcessCommandRunner {
        ProcessCommandRunner()
    }

    func aToolWriting(_ answer: String) -> (executable: URL, arguments: [String]) {
        (URL(fileURLWithPath: "/bin/sh"), ["-c", "printf '%s\\n' \"\(answer)\""])
    }

    func aToolRefusingWith(_ said: String, exitingWith status: Int) -> (executable: URL, arguments: [String]) {
        (URL(fileURLWithPath: "/bin/sh"), ["-c", "printf '%s\\n' \"\(said)\" >&2; exit \(status)"])
    }

    func aToolWritingThenRefusingWith(_ answer: String, said: String, exitingWith status: Int) -> (executable: URL, arguments: [String]) {
        (URL(fileURLWithPath: "/bin/sh"), ["-c", "printf '%s\\n' \"\(answer)\"; printf '%s\\n' \"\(said)\" >&2; exit \(status)"])
    }
}
