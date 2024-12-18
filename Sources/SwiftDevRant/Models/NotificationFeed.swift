import Foundation

/// Contains a list of all notifications for the logged in user and the numbers of unread notifications.
public struct NotificationFeed: Hashable {
    public enum Category: String, CaseIterable {
        case all = ""
        case upvotes = "upvotes"
        case mentions = "mentions"
        case comments = "comments"
        case subscriptions = "subs"
    }
    
    /// The time when the notifications were last checked.
    public let lastChecked: Date
    
    /// The list of all notifications for the logged in user.
    public let notifications: [Notification]
    
    /// The numbers of unread notifications.
    public let unreadNumbers: UnreadNumbers
    
    /// Infos about the user name and avatar for each user id.
    public let userInfos: [UserInfo]
    
    public init(lastChecked: Date, notifications: [Notification], unreadNumbers: NotificationFeed.UnreadNumbers, userInfos: [UserInfo]) {
        self.lastChecked = lastChecked
        self.notifications = notifications
        self.unreadNumbers = unreadNumbers
        self.userInfos = userInfos
    }
}

extension NotificationFeed {
    struct CodingData: Decodable {
        struct Container: Decodable {
            let data: NotificationFeed.CodingData
        }
        
        let check_time: Int
        let items: [Notification.CodingData]
        let unread: UnreadNumbers.CodingData
        let username_map: UserInfo.CodingData.Container
    }
}

extension NotificationFeed.CodingData {
    var decoded: NotificationFeed {
        .init(
            lastChecked: Date(timeIntervalSince1970: TimeInterval(check_time)),
            notifications: items.map(\.decoded),
            unreadNumbers: unread.decoded,
            userInfos: username_map.array.map(\.decoded)
        )
    }
}
