import Foundation

/// A comment posted by a user inside of a rant.
public struct Comment: Identifiable, Hashable {
    /// The id of this comment.
    public let id: Int
    
    /// The id of the rant that the comment belongs to.
    public let rantId: Int
    
    /// The current logged in user's vote on this comment.
    public let voteState: VoteState
    
    /// The number of upvotes from other users.
    public var score: Int
    
    /// The user who wrote this comment.
    public let author: User
    
    /// The time when this comment was created.
    public let created: Date
    
    /// True if this comment is edited by the author.
    public let isEdited: Bool
    
    /// The text contents of this comment.
    public let text: String
    
    /// The URLs and user mentions inside of the text of this comment.
    public var linksInText: [Link]
    
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
