public struct User: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let score: Int
    public let devRantSupporter: Bool
    
    /// The author's avatar, can be used optimally for small portraits of the user.
    //TODO: public let userAvatar: UserAvatar
    
    /// A larger version of the author's avatar, can be used optimally for profile screens.
    //TODO: public let userAvatarLarge: UserAvatar
}
