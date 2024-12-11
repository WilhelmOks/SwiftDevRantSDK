import Foundation

public struct Rant: Identifiable, Hashable {
    /// The id of this rant.
    public let id: Int
    
    /// The text contents of this rant.
    public let text: String
    
    /// The number of upvotes from other users.
    public let score: Int
    
    /// The time when this rant was created.
    public let created: Date
    
    /// The optional image that the user has uploaded for this rant.
    public let image: AttachedImage?
    
    /// The number of comments that this rant has.
    public let numberOfComments: Int
    
    /// The tags for this rant.
    public let tags: [String]
    
    /// The current logged in user's vote on this rant.
    public let voteState: VoteState
    
    /// True if this rant is edited by the author.
    public let isEdited: Bool
    
    /// True if this rant has been marked as a favorite by the logged in user.
    public var isFavorite: Bool
    
    /// A URL link to this rant.
    public let linkToRant: String?
    
    /// The URLs and user mentions inside of the text of this rant.
    public var linksInText: [Link]
    
    /// Holds information about the weekly topic if this rant is of type weekly.
    public let weekly: Weekly?
    
    /// Holds information about the collaboration project if this rant is of type collaboration.
    public let collaboration: Collaboration?
    
    /// The user who wrote this rant.
    public let author: User
}

extension Rant {
    struct CodingData: Codable {
        let id: Int
        let text: String
        let score: Int
        let created_time: Int
        let attached_image: AttachedImage.CodingData?
        let num_comments: Int
        let tags: [String]
        let vote_state: Int
        let edited: Bool
        let favorited: Int?
        let link: String?
        let links: [Link.CodingData]?
        let weekly: Weekly.CodingData?
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
            text: text,
            score: score,
            created: Date(timeIntervalSince1970: TimeInterval(created_time)),
            image: attached_image?.decoded,
            numberOfComments: num_comments,
            tags: tags,
            voteState: .init(rawValue: vote_state) ?? .unvoted,
            isEdited: edited,
            isFavorite: (favorited ?? 0) != 0,
            linkToRant: link,
            linksInText: links?.map(\.decoded) ?? [],
            weekly: weekly?.decoded,
            collaboration: decodedCollaboration,
            author: .init(
                id: user_id,
                name: user_username,
                score: user_score,
                devRantSupporter: (user_dpp ?? 0) != 0,
                avatar: user_avatar.decoded,
                avatarLarge: user_avatar_lg.decoded
            )
        )
    }
    
    private var decodedCollaboration: Collaboration? {
        let collaborationProperties = [c_type_long, c_description, c_tech_stack, c_team_size, c_url]
        let nonNilProperties = collaborationProperties.compactMap { $0 }
        guard !nonNilProperties.isEmpty else { return nil }
        return .init(
            type: c_type_long ?? "",
            description: c_description ?? "",
            techStack: c_tech_stack ?? "",
            teamSize: c_team_size ?? "",
            url: c_url ?? ""
        )
    }
}
