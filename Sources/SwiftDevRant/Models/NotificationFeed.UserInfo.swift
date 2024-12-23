public extension NotificationFeed {
    struct UserInfo: Hashable, Sendable {
        public let avatar: User.Avatar
        public let username: String
        public let userId: Int
        
        public init(avatar: User.Avatar, username: String, userId: Int) {
            self.avatar = avatar
            self.username = username
            self.userId = userId
        }
    }
}

extension NotificationFeed.UserInfo {
    struct UsernameMapEntryCodingData: Decodable {
        let name: String
        let avatar: User.Avatar.CodingData
    }
}
