public extension NotificationFeed {
    /// Holds numbers of unread notifications for each type of notification.
    struct UnreadNumbers: Decodable, Hashable {
        /// The total number of unread notifications
        public let all: Int
        
        /// The number of unread commets.
        public let comments: Int
        
        /// The number of unread mentions.
        public let mentions: Int
        
        /// The number of unread rants from users which the logged in user is subscribed to.
        public let subscriptions: Int
        
        /// The number of unread upvotes.
        public let upvotes: Int
        
        public init(all: Int, comments: Int, mentions: Int, subscriptions: Int, upvotes: Int) {
            self.all = all
            self.comments = comments
            self.mentions = mentions
            self.subscriptions = subscriptions
            self.upvotes = upvotes
        }
    }
}

extension NotificationFeed.UnreadNumbers {
    struct CodingData: Codable {
        let all: Int
        let comments: Int
        let mentions: Int
        let subs: Int
        let upvotes: Int
        //let total: Int //Not needed because it's the same as `all`.
    }
}

extension NotificationFeed.UnreadNumbers.CodingData {
    var decoded: NotificationFeed.UnreadNumbers {
        .init(
            all: all,
            comments: comments,
            mentions: mentions,
            subscriptions: subs,
            upvotes: upvotes
        )
    }
}
