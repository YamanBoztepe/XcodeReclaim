public struct LeftoverListUIModel: Equatable {
    public struct Confirmation: Equatable {
        public let name: String
        public let sentence: String

        public init(name: String, sentence: String) {
            self.name = name
            self.sentence = sentence
        }
    }

    public let title: String
    public let isMeasuring: Bool
    public let leftoverBeingMeasured: String?
    public let nothingToDelete: Bool
    public let deletionMessage: String?
    public let sections: [LeftoverSection]
    public let confirmation: Confirmation?

    public init(
        title: String,
        isMeasuring: Bool,
        leftoverBeingMeasured: String? = nil,
        nothingToDelete: Bool = false,
        deletionMessage: String? = nil,
        sections: [LeftoverSection] = [],
        confirmation: Confirmation? = nil
    ) {
        self.title = title
        self.isMeasuring = isMeasuring
        self.leftoverBeingMeasured = leftoverBeingMeasured
        self.nothingToDelete = nothingToDelete
        self.deletionMessage = deletionMessage
        self.sections = sections
        self.confirmation = confirmation
    }
}
