import Foundation

public struct Rant: Identifiable, Hashable {
    //TODO: public let weekly: Weekly?
    
    /// The id of this rant.
    public let id: Int
    
    /// The text contents of this rant.
    public let text: String
    
    /// The number of upvotes from other users.
    public let score: Int
    
    /// The time when this rant was created.
    public let created: Date
    
    /// If the rant has an image attached to it, a URL of the image will be stored in this.
    //TODO: public let attachedImage: AttachedImage?
    
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
    
    /// A url link to this rant.
    public let link: String?
    
    /// If the rant includes URLs in the text, those that were successfully parsed by the server will be in this array.
    //TODO: public var links: [Link]?
    
    /// Holds information about the collaboration project if this rant is of type collaboration.
    let collaboration: Collaboration?
    
    /// The user who wrote this rant.
    let author: User
}

extension Rant {
    struct CodingData: Codable {
        let id: Int
        let text: String
        let score: Int
        let created_time: Int
        //TODO: let attachedImage: AttachedImage?
        let num_comments: Int
        let tags: [String]
        let vote_state: Int
        //TODO: let weekly: Weekly?
        let edited: Bool
        let favorited: Int?
        let link: String?
        //TODO: let links: [Link]
        let c_type_long: String?
        let c_description: String?
        let c_tech_stack: String?
        let c_team_size: String?
        let c_url: String?
        let user_id: Int
        let user_username: String
        let user_score: Int
        //TODO: let user_avatar: UserAvatar
        //TODO: let user_avatar_lg: UserAvatar
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
            numberOfComments: num_comments,
            tags: tags,
            voteState: .init(rawValue: vote_state) ?? .unvoted,
            isEdited: edited,
            isFavorite: (favorited ?? 0) != 0,
            link: link,
            collaboration: decodedCollaboration,
            author: .init(
                id: user_id,
                name: user_username,
                score: user_score,
                devRantSupporter: (user_dpp ?? 0) != 0
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
