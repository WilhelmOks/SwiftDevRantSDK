import Foundation

/// A comment posted by a user inside of a rant.
public struct Comment: Identifiable, Hashable, Sendable {
    /// The id of this comment.
    public let id: Int
    
    /// The id of the rant that the comment belongs to.
    public let rantId: Int
    
    /// The current logged in user's vote on this comment.
    public let voteState: VoteState
    
    /// The number of upvotes from other users.
    public let score: Int
    
    /// The user who wrote this comment.
    public let author: User
    
    /// The time when this comment was created.
    public let created: Date
    
    /// True if this comment is edited by the author.
    public let isEdited: Bool
    
    /// The text contents of this comment.
    public let text: String
    
    /// The URLs and user mentions inside of the text of this comment.
    public let linksInText: [Link]
    
    /// The optional image that the user has uploaded for this comment.
    public let image: AttachedImage?
    
    public init(id: Int, rantId: Int, voteState: VoteState, score: Int, author: User, created: Date, isEdited: Bool, text: String, linksInText: [Link], image: AttachedImage?) {
        self.id = id
        self.rantId = rantId
        self.voteState = voteState
        self.score = score
        self.author = author
        self.created = created
        self.isEdited = isEdited
        self.text = text
        self.linksInText = linksInText
        self.image = image
    }
}

extension Comment {
    struct CodingData: Decodable {
        let id: Int
        let rant_id: Int
        let body: String
        let score: Int
        let created_time: Int
        let vote_state: Int
        let links: [Link.CodingData]?
        let user_id: Int
        let user_username: String
        let user_score: Int
        let user_avatar: User.Avatar.CodingData
        let user_avatar_lg: User.Avatar.CodingData?
        let user_dpp: Int?
        let attached_image: AttachedImage.CodingData?
        let edited: Bool?
    }
}

extension Comment.CodingData {
    var decoded: Comment {
        .init(
            id: id,
            rantId: rant_id,
            voteState: .init(rawValue: vote_state) ?? .unvoted,
            score: score,
            author: .init(
                id: user_id,
                name: user_username,
                score: user_score,
                devRantSupporter: (user_dpp ?? 0) != 0,
                avatarSmall: user_avatar.decoded,
                avatarLarge: user_avatar_lg?.decoded
            ),
            created: Date(timeIntervalSince1970: TimeInterval(created_time)),
            isEdited: edited ?? false,
            text: body,
            linksInText: links?.map(\.decoded) ?? [],
            image: attached_image?.decoded
        )
    }
}
