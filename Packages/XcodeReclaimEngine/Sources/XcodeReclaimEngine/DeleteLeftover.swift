import Foundation
import XcodeReclaimCore

public struct DeleteLeftover {
    private let disk: any Disk
    private let simulatorService: any SimulatorService

    public init(disk: any Disk, simulatorService: any SimulatorService) {
        self.disk = disk
        self.simulatorService = simulatorService
    }

    public func delete(_ leftover: Leftover) -> Deletion {
        if let refusal = leftover.refusal {
            return .refused(refusal)
        }

        do {
            try remove(leftover.place)
            return .freed(leftover.bytes)
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}

private extension DeleteLeftover {
    func remove(_ place: Leftover.Place) throws {
        switch place {
        case .folder(let url), .xcodeCopy(let url):
            try disk.removeItem(at: url)
        case .simulator(let identifier):
            try simulatorService.delete(simulatorWithIdentifier: identifier)
        }
    }
}
