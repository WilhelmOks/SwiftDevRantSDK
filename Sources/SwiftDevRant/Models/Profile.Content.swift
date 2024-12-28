public extension Profile {
    struct Content: Hashable, Sendable {
        public let elements: Elements
        public let numbers: Numbers
        
        public init(elements: Profile.Content.Elements, numbers: Profile.Content.Numbers) {
            self.elements = elements
            self.numbers = numbers
        }
    }
}

extension Profile.Content {
    struct CodingData: Decodable {
        let content: Elements.CodingData
        let counts: Numbers.CodingData
    }
}

extension Profile.Content.CodingData {
    var decoded: Profile.Content {
        .init(
            elements: content.decoded,
            numbers: counts.decoded
        )
    }
}
