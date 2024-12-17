/// Contains the list of rants for the logged in user and other random things.
public struct RantFeed: Hashable {
    public let rants: [Rant]
    
    public let sessionHash: String?
    
    /// The weekly group rant week number.
    public let weeklyRantWeek: Int?
    
    /// True if the logged in user is subscribed to devRant++.
    public let devRantSupporter: Bool
    
    public let numberOfUnreadNotifications: Int
    
    public let news: News?
    
    public init(rants: [Rant], sessionHash: String?, weeklyRantWeek: Int?, devRantSupporter: Bool, numberOfUnreadNotifications: Int, news: RantFeed.News?) {
        self.rants = rants
        self.sessionHash = sessionHash
        self.weeklyRantWeek = weeklyRantWeek
        self.devRantSupporter = devRantSupporter
        self.numberOfUnreadNotifications = numberOfUnreadNotifications
        self.news = news
    }
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

extension RantFeed {
    struct CodingData: Codable {
        let rants: [Rant.CodingData]
        //let settings //not sure what the purpose is. probably not needed.
        let set: String?
        let wrw: Int?
        let dpp: Int?
        let num_notifs: Int?
        //let unread //probably the same info as already provided by num_notifs, so not needed.
        let news: News.CodingData?
    }
}

extension RantFeed.CodingData {
    var decoded: RantFeed {
        .init(
            rants: rants.map(\.decoded),
            sessionHash: `set`,
            weeklyRantWeek: wrw,
            devRantSupporter: (dpp ?? 0) != 0,
            numberOfUnreadNotifications: num_notifs ?? 0,
            news: news?.decoded
        )
    }
}
