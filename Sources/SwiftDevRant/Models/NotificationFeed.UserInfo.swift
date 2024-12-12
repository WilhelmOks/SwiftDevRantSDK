public extension NotificationFeed {
    struct UserInfo: Hashable {
        public let avatar: User.Avatar
        public let username: String
        public let userId: String //TODO: why is this String? The other user ids are Int.
        
        public init(avatar: User.Avatar, username: String, userId: String) {
            self.avatar = avatar
            self.username = username
            self.userId = userId
        }
    }
}

extension NotificationFeed.UserInfo {
    struct CodingData: Decodable {
        struct Container: Decodable {
            let array: [CodingData]
        }
        
        let avatar: User.Avatar.CodingData
        let name: String
        let uidForUsername: String //TODO: why is this String? The other user ids are Int.
        
        private enum CodingKeys: CodingKey {
            case avatar
            case name
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            avatar = try values.decode(User.Avatar.CodingData.self, forKey: .avatar)
            name = try values.decode(String.self, forKey: .name)
            
            uidForUsername = values.codingPath[values.codingPath.endIndex - 1].stringValue //TODO: wtf is this? Check if it can be made simpler and easier to understand.
        }
    }
}

extension NotificationFeed.UserInfo.CodingData {
    var decoded: NotificationFeed.UserInfo {
        .init(
            avatar: avatar.decoded,
            username: name,
            userId: uidForUsername
        )
    }
}
