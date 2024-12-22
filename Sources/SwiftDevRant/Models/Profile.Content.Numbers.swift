public extension Profile.Content {
    struct Numbers: Hashable, Sendable {
        /// The number of rants that the user has created.
        public let rants: Int
        
        /// The number of rants that the user has upvoted.
        public let upvotedRants: Int
        
        /// The number of the comments that the user has created.
        public let comments: Int
        
        /// The number of rants that the user has marked as favorite.
        public let favorites: Int
        
        /// The number of collaborations the user has created.
        public let collaborations: Int
        
        public init(rants: Int, upvotedRants: Int, comments: Int, favorites: Int, collaborations: Int) {
            self.rants = rants
            self.upvotedRants = upvotedRants
            self.comments = comments
            self.favorites = favorites
            self.collaborations = collaborations
        }
    }
}

extension Profile.Content.Numbers {
    struct CodingData: Codable {
        let rants: Int
        let upvoted: Int
        let comments: Int
        let favorites: Int
        let collabs: Int
    }
}

extension Profile.Content.Numbers.CodingData {
    var decoded: Profile.Content.Numbers {
        .init(
            rants: rants,
            upvotedRants: upvoted,
            comments: comments,
            favorites: favorites,
            collaborations: collabs
        )
    }
}
