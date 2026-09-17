public struct LeftoverListUIModel: Equatable {
    public struct Confirmation: Equatable {
        public let question: String
        public let sentence: String

        public init(question: String, sentence: String) {
            self.question = question
            self.sentence = sentence
        }
    }

    public struct Sorting: Equatable {
        public enum Column: Equatable {
            case name
            case size
        }

        public let column: Column
        public let isAscending: Bool

        public init(column: Column, isAscending: Bool) {
            self.column = column
            self.isAscending = isAscending
        }

        public static var biggestFirst: Sorting { Sorting(column: .size, isAscending: false) }
    }

    public let title: String
    public let isMeasuring: Bool
    public let leftoverBeingMeasured: String?
    public let nothingToDelete: Bool
    public let deletionMessage: String?
    public let sections: [LeftoverSection]
    public let selection: Set<String>
    public let sorting: Sorting
    public let canDeleteSelection: Bool
    public let confirmation: Confirmation?

    public init(
        title: String,
        isMeasuring: Bool,
        leftoverBeingMeasured: String? = nil,
        nothingToDelete: Bool = false,
        deletionMessage: String? = nil,
        sections: [LeftoverSection] = [],
        selection: Set<String> = [],
        sorting: Sorting = .biggestFirst,
        canDeleteSelection: Bool = false,
        confirmation: Confirmation? = nil
    ) {
        self.title = title
        self.isMeasuring = isMeasuring
        self.leftoverBeingMeasured = leftoverBeingMeasured
        self.nothingToDelete = nothingToDelete
        self.deletionMessage = deletionMessage
        self.sections = sections
        self.selection = selection
        self.sorting = sorting
        self.canDeleteSelection = canDeleteSelection
        self.confirmation = confirmation
    }
}
