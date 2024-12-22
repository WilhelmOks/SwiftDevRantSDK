import Foundation

public extension NotificationFeed {
    public struct MappedNotificationItem: Hashable, Sendable {
        public let rantId: Rant.ID
        public let commentId: Comment.ID?
        public let userId: Int
        public let userAvatar: User.Avatar
        public let userName: String
        public let notificationKind: Notification.Kind
        public let created: Date
        public let isRead: Bool
        
        public init(rantId: Rant.ID, commentId: Comment.ID?, userId: Int, userAvatar: User.Avatar, userName: String, notificationKind: Notification.Kind, created: Date, isRead: Bool) {
            self.rantId = rantId
            self.commentId = commentId
            self.userId = userId
            self.userAvatar = userAvatar
            self.userName = userName
            self.notificationKind = notificationKind
            self.created = created
            self.isRead = isRead
        }
    }
    
    public var mappedItems: [MappedNotificationItem] {
        notifications.map { notification in
            let rantId = notification.rantId
            let commentId = notification.commentId
            let userId = notification.userId
            let userInfo = userInfos.first { $0.userId == String(userId) }
            let userAvatar = userInfo?.avatar ?? .init(colorHex: "cccccc", imageUrlPath: nil)
            let userName = userInfo?.username ?? ""
            
            return MappedNotificationItem(
                rantId: rantId,
                commentId: commentId,
                userId: userId,
                userAvatar: userAvatar,
                userName: userName,
                notificationKind: notification.kind,
                created: notification.created,
                isRead: notification.read
            )
        }
    }
    
    public var unreadByCategory: [NotificationFeed.Category: Int] {
        [
            .all:           unreadNumbers.all,
            .upvotes:       unreadNumbers.upvotes,
            .mentions:      unreadNumbers.mentions,
            .comments:      unreadNumbers.comments,
            .subscriptions: unreadNumbers.subscriptions,
        ]
    }
}
