public extension User {
    struct Avatar: Hashable {
        public let colorHex: String
        
        public let imageUrlPath: String?
        
        public var imageUrl: String? {
            imageUrlPath.flatMap { "https://avatars.devrant.com/\($0)" }
        }
        
        public init(colorHex: String, imageUrlPath: String?) {
            self.colorHex = colorHex
            self.imageUrlPath = imageUrlPath
        }
    }
}

extension User.Avatar {
    struct CodingData: Codable {
        let b: String
        let i: String?
    }
}

extension User.Avatar.CodingData {
    var decoded: User.Avatar {
        .init(
            colorHex: b,
            imageUrlPath: i
        )
    }
}
