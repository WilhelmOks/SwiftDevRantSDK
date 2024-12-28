import Foundation

/// Holds information, content and the activity history of a user.
public struct Profile: Hashable, Sendable {
    /// The user's alias.
    public let username: String
    
    /// The number of upvotes that the user got from other users.
    public let score: Int
    
    /// The time when the user created the account.
    public let created: Date
    
    /// The description of the user.
    public let about: String?
    
    /// The description of the geographic location.
    public let location: String?
    
    /// The description of the user's skills.
    public let skills: String?
    
    /// The user's GitHub reference.
    public let github: String?
    
    /// The user's personal website.
    public let website: String?
    
    /// The user's content and activities.
    public let content: Content
    
    /// The user's large avatar, for profile views.
    public let avatarLarge: User.Avatar
    
    /// The user's small avatar, for rant views and comment views.
    public let avatarSmall: User.Avatar
    
    /// True if the user is subscribed to devRant++.
    public let devRantSupporter: Bool
    
    /// True if the logged in user is subscribed to the user of this profile.
    public var subscribed: Bool
    
    public init(username: String, score: Int, created: Date, about: String?, location: String?, skills: String?, github: String?, website: String?, content: Profile.Content, avatarLarge: User.Avatar, avatarSmall: User.Avatar, devRantSupporter: Bool, subscribed: Bool) {
        self.username = username
        self.score = score
        self.created = created
        self.about = about
        self.location = location
        self.skills = skills
        self.github = github
        self.website = website
        self.content = content
        self.avatarLarge = avatarLarge
        self.avatarSmall = avatarSmall
        self.devRantSupporter = devRantSupporter
        self.subscribed = subscribed
    }
}

public extension Profile {
    enum ContentType: String, Sendable {
        /// All user content.
        case all = "all"
        
        /// The user's rants.
        case rants = "rants"
        
        /// The user's comments.
        case comments = "comments"
        
        /// Rants or comments upvoted by the user.
        case upvoted = "upvoted"
        
        /// The user's favorite rants.
        case favorite = "favorites"
        
        /// The rants viewd by the user.
        case viewed = "viewed"
    }
}

extension Profile {
    struct CodingData: Decodable {
        struct Container: Decodable {
            let profile: Profile.CodingData
            let subscribed: Int?
        }
        
        let username: String
        let score: Int
        let created_time: Int
        let about: String
        let location: String
        let skills: String
        let github: String
        let website: String
        let content: Content.CodingData
        let avatar: User.Avatar.CodingData
        let avatar_sm: User.Avatar.CodingData
        let dpp: Int?
    }
}

extension Profile.CodingData.Container {
    var decoded: Profile {
        return .init(
            username: profile.username,
            score: profile.score,
            created: Date(timeIntervalSince1970: TimeInterval(profile.created_time)),
            about: profile.about.isEmpty ? nil : profile.about,
            location: profile.location.isEmpty ? nil : profile.location,
            skills: profile.skills.isEmpty ? nil : profile.skills,
            github: profile.github.isEmpty ? nil : profile.github,
            website: profile.website.isEmpty ? nil : profile.website,
            content: profile.content.decoded,
            avatarLarge: profile.avatar.decoded,
            avatarSmall: profile.avatar_sm.decoded,
            devRantSupporter: (profile.dpp ?? 0) != 0,
            subscribed: (subscribed ?? 0) != 0
        )
    }
}
