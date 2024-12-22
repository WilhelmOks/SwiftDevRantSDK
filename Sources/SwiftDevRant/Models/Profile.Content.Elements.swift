public extension Profile.Content {
    struct Elements: Hashable, Sendable {
        /// The rants that the user has created.
        public let rants: [Rant]
        
        /// The rants that the user has upvoted.
        public let upvotedRants: [Rant]
        
        /// The comments that the user has created.
        public let comments: [Comment]
        
        /// The rants that the user has marked as favorite.
        public let favorites: [Rant]
        
        /// If the profile is from the logged in user, then this list contains rants that user has viewed in the past.
        public let viewed: [Rant]
        
        public init(rants: [Rant], upvotedRants: [Rant], comments: [Comment], favorites: [Rant], viewed: [Rant]) {
            self.rants = rants
            self.upvotedRants = upvotedRants
            self.comments = comments
            self.favorites = favorites
            self.viewed = viewed
        }
    }
}

extension Profile.Content.Elements {
    struct CodingData: Codable {
        let rants: [Rant.CodingData]
        let upvoted: [Rant.CodingData]
        let comments: [Comment.CodingData]
        let favorites: [Rant.CodingData]?
        let viewed: [Rant.CodingData]?
    }
}

extension Profile.Content.Elements.CodingData {
    var decoded: Profile.Content.Elements {
        .init(
            rants: rants.map(\.decoded),
            upvotedRants: upvoted.map(\.decoded),
            comments: comments.map(\.decoded),
            favorites: favorites?.map(\.decoded) ?? [],
            viewed: viewed?.map(\.decoded) ?? []
        )
    }
}
