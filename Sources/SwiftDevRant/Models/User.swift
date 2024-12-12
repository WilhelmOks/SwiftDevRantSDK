public struct User: Identifiable, Hashable {
    public let id: Int
    
    public let name: String
    
    /// The number of upvotes from other users.
    public let score: Int
    
    /// True if the logged in user is subscribed to devRant++.
    public let devRantSupporter: Bool
    
    /// A small avatar for the rant views and comment views.
    public let avatar: Avatar
    
    /// A large avatar for the profile view.
    public let avatarLarge: Avatar?
    
    public init(id: Int, name: String, score: Int, devRantSupporter: Bool, avatar: User.Avatar, avatarLarge: User.Avatar?) {
        self.id = id
        self.name = name
        self.score = score
        self.devRantSupporter = devRantSupporter
        self.avatar = avatar
        self.avatarLarge = avatarLarge
    }
}
