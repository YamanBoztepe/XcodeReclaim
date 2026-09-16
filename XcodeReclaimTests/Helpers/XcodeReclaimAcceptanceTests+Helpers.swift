import Foundation
import XcodeReclaim
import XcodeReclaimEngine

@MainActor
func appMeasuring(
    foldersHolding folders: [URL: Int] = [:],
    simulatorsTaking simulators: [Int] = [],
    copiesOfXcodeTaking copies: [Int] = []
) -> LeftoverListContainerView {
    appMeasuring(withDisk: DiskStub(holding: folders), simulatorsTaking: simulators, copiesOfXcodeTaking: copies)
}

@MainActor
func appMeasuring(
    withDisk disk: any Disk & Sendable,
    simulatorsTaking simulators: [Int] = [],
    copiesOfXcodeTaking copies: [Int] = []
) -> LeftoverListContainerView {
    let anythingIsWorthDeleting = 1

    return XcodeReclaim(
        developerFolder: developerFolder,
        worthDeleting: anythingIsWorthDeleting,
        disk: { disk },
        simulatorService: { SimulatorServiceStub(eachTaking: simulators) },
        xcodeCopyLoader: { XcodeCopyLoaderStub(eachTaking: copies) }
    )
    .leftoverList()
}
