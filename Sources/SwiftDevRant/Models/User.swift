public struct User: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let score: Int
    public let devRantSupporter: Bool
    
    /// A small avatar for the rant views and comment views.
    public let avatar: Avatar
    
    /// A large avatar for the profile view.
    public let avatarLarge: Avatar
}
