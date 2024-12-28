public extension Rant {
    /// Holds information about a specific weekly group rant.
    struct Weekly: Hashable, Sendable {
        public let week: Int
        public let topic: String
        public let date: String
        public let uiHeight: Int
        
        public init(week: Int, topic: String, date: String, uiHeight: Int) {
            self.week = week
            self.topic = topic
            self.date = date
            self.uiHeight = uiHeight
        }
    }
}

extension Rant.Weekly {
    struct CodingData: Decodable {
        let week: Int
        let topic: String
        let date: String
        let height: Int
    }
}

extension Rant.Weekly.CodingData {
    var decoded: Rant.Weekly {
        .init(
            week: week,
            topic: topic,
            date: date,
            uiHeight: height
        )
    }
}
