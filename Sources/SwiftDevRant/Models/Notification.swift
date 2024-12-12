import Foundation

/// A notification about activities in a rant or a comment.
public struct Notification: Hashable, Identifiable {
    public enum Kind: String {
        /// An upvote for a rant.
        case rantUpvote = "content_vote"
        
        /// An upvote for a comment.
        case commentUpvote = "comment_vote"
        
        /// A new comment in one of the logged in user's rants.
        case newCommentInOwnRant = "comment_content"
        
        /// A new comment in a rant that the logged in user has commented in.
        case newComment = "comment_discuss"
        
        /// A mention of the logged in user in a comment.
        case mentionInComment = "comment_mention"
        
        /// A new rant posted by someone that the logged in user is subscribed to.
        case newRantOfSubscribedUser = "rant_sub"
    }
    
    /// The id of the rant associated with this notification.
    public let rantId: Int
    
    /// The id of the comment associated with this notification, if this notification is for a comment.
    public let commentId: Int?
    
    /// The time when this notification was created.
    public let created: Date
    
    /// True if the user has already read this notification.
    public let read: Bool
    
    /// The type of this notification.
    public let kind: Kind
    
    /// The id of the user who triggered the notification.
    public let userId: Int
    
    public var id: String {
        [
            String(rantId),
            commentId.flatMap{ String($0) } ?? "-",
            String(Int(created.timeIntervalSince1970)),
            String(read),
            kind.rawValue,
            String(userId)
        ].joined(separator: "|")
    }
    
    public init(rantId: Int, commentId: Int?, created: Date, read: Bool, kind: Notification.Kind, userId: Int) {
        self.rantId = rantId
        self.commentId = commentId
        self.created = created
        self.read = read
        self.kind = kind
        self.userId = userId
    }
}

extension Notification {
    struct CodingData: Codable {
        let rant_id: Int
        let comment_id: Int?
        let created_time: Int
        let read: Int
        let type: String
        let uid: Int
    }
}

extension Notification.CodingData {
    var decoded: Notification {
        .init(
            rantId: rant_id,
            commentId: comment_id,
            created: Date(timeIntervalSince1970: TimeInterval(created_time)),
            read: read != 0,
            kind: .init(rawValue: type) ?? .newComment,
            userId: uid
        )
    }
}
