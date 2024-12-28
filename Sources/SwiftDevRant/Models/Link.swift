/// A URL or a user mention link in a rant or comment.
public struct Link: Hashable, Sendable {
    public enum Kind: String, Sendable {
        case url = "url"
        case userMention = "mention"
    }
    
    public let kind: Kind
    
    /// The full URL.
    public let url: String
    
    /// No idea what this is and what it is supposed to be used for.
    public let shortURL: String?
    
    /// The url as it is visible in the text of the rant or comment.
    public let title: String
    
    /// The starting position of the link in the overall text of the rant or comment.
    /// - Important: The devRant API returns offsets for links in byte offsets and not in normalized character offsets. Please take this into account when using these offsets.
    public let start: Int?
    
    /// The ending position of the link in the overall text of the rant or comment.
    /// - Important: The devRant API returns offsets for links in byte offsets and not in normalized character offsets. Please take this into account when using these offsets.
    public let end: Int?
    
    public init(kind: Link.Kind, url: String, shortURL: String?, title: String, start: Int?, end: Int?) {
        self.kind = kind
        self.url = url
        self.shortURL = shortURL
        self.title = title
        self.start = start
        self.end = end
    }
}

extension Link {
    struct CodingData: Decodable {
        let type: String
        let url: StringOrIntDecodable
        let short_url: String?
        let title: String
        let start: Int?
        let end: Int?
    }
}

extension Link.CodingData {
    var decoded: Link {
        .init(
            kind: .init(rawValue: type) ?? .url,
            url: url.decodedAsString(),
            shortURL: short_url,
            title: title,
            start: start,
            end: end
        )
    }
}
