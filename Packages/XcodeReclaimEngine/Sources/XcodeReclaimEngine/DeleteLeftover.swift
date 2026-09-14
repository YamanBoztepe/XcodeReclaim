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
            let wasThere = try remove(leftover.place)
            return .freed(wasThere ? leftover.bytes : 0)
        } catch {
            return whatIsLeft(of: leftover, refusedSaying: error.localizedDescription)
        }
    }
}

private extension DeleteLeftover {
    func whatIsLeft(of leftover: Leftover, refusedSaying why: String) -> Deletion {
        guard let folder = folder(holding: leftover.place) else { return .failed(why) }

        let stillThere = disk.bytesUsedByFolder(at: folder)
        guard stillThere > 0, stillThere < leftover.bytes else { return .failed(why) }

        return .partlyFreed(leftover.bytes - stillThere, stillThere: stillThere, why: why)
    }

    func folder(holding place: Leftover.Place) -> URL? {
        switch place {
        case .folder(let url), .xcodeCopy(let url): url
        case .simulator: nil
        }
    }

    func remove(_ place: Leftover.Place) throws -> Bool {
        switch place {
        case .folder(let url), .xcodeCopy(let url):
            return try disk.removeItem(at: url)
        case .simulator(let identifier):
            try simulatorService.delete(simulatorWithIdentifier: identifier)
            return true
        }
    }
}
