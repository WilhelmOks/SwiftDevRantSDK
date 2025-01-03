import Foundation

public struct Rant: Identifiable, Hashable, Sendable {
    /// The id of this rant.
    public let id: Int
    
    /// A URL link to this rant.
    public let linkToRant: String?
    
    /// The current logged in user's vote on this rant.
    public let voteState: VoteState
    
    /// The number of upvotes from other users.
    public let score: Int
    
    /// The user who wrote this rant.
    public let author: User
    
    /// The time when this rant was created.
    public let created: Date
    
    /// True if this rant is edited by the author.
    public let isEdited: Bool
    
    /// True if this rant has been marked as a favorite by the logged in user.
    public var isFavorite: Bool
    
    /// The text contents of this rant.
    public let text: String
    
    /// The URLs and user mentions inside of the text of this rant.
    public let linksInText: [Link]
    
    /// The optional image that the user has uploaded for this rant.
    public let image: AttachedImage?
    
    /// The number of comments that this rant has.
    public let numberOfComments: Int
    
    /// The tags for this rant.
    public let tags: [String]
    
    /// Holds information about the weekly topic if this rant is of type weekly.
    public let weekly: Weekly?
    
    /// Holds information about the collaboration project if this rant is of type collaboration.
    public let collaboration: Collaboration?
    
    public init(id: Int, linkToRant: String?, voteState: VoteState, score: Int, author: User, created: Date, isEdited: Bool, isFavorite: Bool, text: String, linksInText: [Link], image: AttachedImage?, numberOfComments: Int, tags: [String], weekly: Rant.Weekly?, collaboration: Collaboration?) {
        self.id = id
        self.linkToRant = linkToRant
        self.voteState = voteState
        self.score = score
        self.author = author
        self.created = created
        self.isEdited = isEdited
        self.isFavorite = isFavorite
        self.text = text
        self.linksInText = linksInText
        self.image = image
        self.numberOfComments = numberOfComments
        self.tags = tags
        self.weekly = weekly
        self.collaboration = collaboration
    }
}

extension Rant {
    struct CodingData: Decodable {
        let id: Int
        let text: String
        let score: Int
        let created_time: Int
        let attached_image: StringOrObjectDecodable<AttachedImage.CodingData>?
        let num_comments: Int
        let tags: [String]
        let vote_state: Int
        let edited: Bool
        let favorited: Int?
        let link: String?
        let links: [Link.CodingData]?
        let weekly: Weekly.CodingData?
        let c_type: Int?
        let c_type_long: String?
        let c_description: String?
        let c_tech_stack: String?
        let c_team_size: String?
        let c_url: String?
        let user_id: Int
        let user_username: String
        let user_score: Int
        let user_avatar: User.Avatar.CodingData
        let user_avatar_lg: User.Avatar.CodingData
        let user_dpp: Int?
    }
}

extension Rant.CodingData {
    var decoded: Rant {
        .init(
            id: id,
            linkToRant: link,
            voteState: .init(rawValue: vote_state) ?? .unvoted,
            score: score,
            author: .init(
                id: user_id,
                name: user_username,
                score: user_score,
                devRantSupporter: (user_dpp ?? 0) != 0,
                avatarSmall: user_avatar.decoded,
                avatarLarge: user_avatar_lg.decoded
            ),
            created: Date(timeIntervalSince1970: TimeInterval(created_time)),
            isEdited: edited,
            isFavorite: (favorited ?? 0) != 0,
            text: text,
            linksInText: links?.map(\.decoded) ?? [],
            image: attached_image?.decodedAsObject()?.decoded,
            numberOfComments: num_comments,
            tags: tags,
            weekly: weekly?.decoded,
            collaboration: decodedCollaboration
        )
    }
    
    private var decodedCollaboration: Collaboration? {
        guard c_type != nil || c_type_long != nil || c_description != nil || c_tech_stack != nil || c_team_size != nil || c_url != nil else {
            return nil
        }
        return .init(
            kind: c_type.flatMap { .init(rawValue: $0) },
            kindDescription: c_type_long ?? "",
            description: c_description ?? "",
            techStack: c_tech_stack ?? "",
            teamSize: c_team_size ?? "",
            url: c_url ?? ""
        )
    }
}
