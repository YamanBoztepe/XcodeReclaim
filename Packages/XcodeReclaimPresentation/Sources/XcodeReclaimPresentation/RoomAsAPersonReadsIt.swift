private let tenthsPerUnit = 10
private let halvesInAUnit = 2
private let kilobyte = 1_000
private let units: [(divisor: Int, unit: String)] = [
    (kilobyte * kilobyte * kilobyte * kilobyte, "TB"),
    (kilobyte * kilobyte * kilobyte, "GB"),
    (kilobyte * kilobyte, "MB"),
    (kilobyte, "KB"),
]

extension LeftoverListViewModel {
    func roomWritten(_ bytes: Int) -> String {
        guard let read = unitReading(of: bytes) else { return "\(bytes) bytes" }

        return "\(read.tenths / tenthsPerUnit).\(read.tenths % tenthsPerUnit) \(read.unit)"
    }

    func roomRounded(_ bytes: Int) -> Int {
        guard let read = unitReading(of: bytes) else { return bytes }

        return read.tenths * (read.divisor / tenthsPerUnit)
    }
}

private extension LeftoverListViewModel {
    func unitReading(of bytes: Int) -> (tenths: Int, divisor: Int, unit: String)? {
        guard let read = units.first(where: { bytes >= $0.divisor }) else { return nil }

        let roundingUpFromAHalf = read.divisor / halvesInAUnit
        return (tenths: (bytes * tenthsPerUnit + roundingUpFromAHalf) / read.divisor, divisor: read.divisor, unit: read.unit)
    }
}
