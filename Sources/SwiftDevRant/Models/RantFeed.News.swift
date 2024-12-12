public extension RantFeed {
    /// Contains information about news given in rant feeds.
    /// - note: This is mostly used for weekly group rants.
    struct News: Hashable, Identifiable {
        public enum Action: String {
            case groupRant = "grouprant"
            case none = "none"
            case rant = "rant"
        }
        
        public let id: Int
        
        /// Most of the time this is equal to the value `intlink`, this specifies the type of news.
        /// This should be an enum but it's unknown what the other values are and weekly news are dead anyway.
        public let type: String
        
        /// The headline text of the news.
        public let headlineText: String
        
        /// The contents of the news.
        public let text: String
        
        /// The footer text of the news.
        public let footerText: String
        
        /// The height of the news view on the screen.
        public let height: Int
        
        /// The action that should be performed when the user taps/clicks on the news.
        public let action: Action
        
        public init(id: Int, type: String, headlineText: String, text: String, footerText: String, height: Int, action: Action) {
            self.id = id
            self.type = type
            self.headlineText = headlineText
            self.text = text
            self.footerText = footerText
            self.height = height
            self.action = action
        }
    }
}

extension RantFeed.News {
    struct CodingData: Codable {
        let id: Int
        let type: String
        let headline: String
        let body: String?
        let footer: String
        let height: Int
        let action: String
    }
}

extension RantFeed.News.CodingData {
    var decoded: RantFeed.News {
        .init(
            id: id,
            type: type,
            headlineText: headline,
            text: body ?? "",
            footerText: footer,
            height: height,
            action: .init(rawValue: action) ?? .none
        )
    }
}
