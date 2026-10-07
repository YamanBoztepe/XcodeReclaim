import Foundation
import XcodeReclaim
import XcodeReclaimEngine

@MainActor
func appMeasuring(
    foldersHolding folders: [URL: Int] = [:],
    simulatorsTaking simulators: [Int] = [],
    copiesOfXcodeTaking copies: [Int] = [],
    runtimesTaking runtimes: [Int] = [],
    archivesTaking archives: [Int] = [],
    toolchainsTaking toolchains: [Int] = []
) -> LeftoverListContainerView {
    appMeasuring(
        withDisk: DiskStub(holding: folders), simulatorsTaking: simulators, copiesOfXcodeTaking: copies, runtimesTaking: runtimes,
        archivesTaking: archives, toolchainsTaking: toolchains)
}

@MainActor
func appMeasuring(
    withDisk disk: any MeasureLeftovers.Disk & DeleteLeftover.Disk & Sendable,
    simulatorsTaking simulators: [Int] = [],
    copiesOfXcodeTaking copies: [Int] = [],
    runtimesTaking runtimes: [Int] = [],
    archivesTaking archives: [Int] = [],
    toolchainsTaking toolchains: [Int] = []
) -> LeftoverListContainerView {
    let anythingIsWorthDeleting = 1

    return XcodeReclaim(
        developerFolder: developerFolder,
        cachesFolder: cachesFolder,
        worthDeleting: anythingIsWorthDeleting,
        disk: { disk },
        simulatorService: { SimulatorServiceStub(eachTaking: simulators) },
        runtimeService: { RuntimeServiceStub(eachTaking: runtimes) },
        xcodeCopyLoader: { XcodeCopyLoaderStub(eachTaking: copies) },
        archiveLoader: { ArchiveLoaderStub(eachTaking: archives) },
        toolchainLoader: { ToolchainLoaderStub(eachTaking: toolchains) },
        calendar: calendarInGreenwich
    )
    .leftoverList()
}
