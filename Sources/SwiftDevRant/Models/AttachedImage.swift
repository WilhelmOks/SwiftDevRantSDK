/// An image that the user has uploaded for his rant or comment.
public struct AttachedImage: Hashable {
    public let url: String
    public let width: Int
    public let height: Int
    
    public init(url: String, width: Int, height: Int) {
        self.url = url
        self.width = width
        self.height = height
    }
}

extension AttachedImage {
    struct CodingData: Codable {
        let url: String
        let width: Int
        let height: Int
    }
}

extension AttachedImage.CodingData {
    var decoded: AttachedImage {
        .init(
            url: url,
            width: width,
            height: height
        )
    }
}
