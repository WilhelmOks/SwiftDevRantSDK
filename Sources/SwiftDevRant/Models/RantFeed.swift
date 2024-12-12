/// Contains the list of rants for the logged in user and other random things.
public struct RantFeed: Hashable {
    public var rants: [Rant]
    
    /// The notification settings for the logged-in user.
    //public let settings: Settings
    
    public let sessionHash: String?
    
    /// The weekly group rant week number.
    public let weeklyRantWeek: Int?
    
    /// True if the logged in user is subscribed to devRant++.
    public let devRantSupporter: Bool
    //public let isUserDPP: Int
    
    public let numberOfUnreadNotifications: Int
    
    public let news: News?
}

public extension RantFeed {
    enum Sort {
        /// The devRant algorithm decides what rants appear in the feed.
        case algorithm
        
        /// The most recent rants appear in the feed.
        case recent
        
        /// The top rated rants appear in the feed.
        case top(range: Range)
    }
    
    enum Range {
        /// Rants from the one day.
        case day
        
        /// Rants from the one week.
        case week
        
        /// Rants from the one month.
        case month
        
        /// Rants from all time.
        case all
    }
}
