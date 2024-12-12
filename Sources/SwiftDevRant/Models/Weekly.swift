/// The weekly item data for the list of weeklies.
public struct Weekly: Hashable, Identifiable {
    /// The number of the week. The first week starts with 1.
    public let week: Int
    
    /// The weekly subject/topic.
    public let topic: String
    
    /// The US formatted date the weekly.
    public let formattedDate: String
    
    /// How many rants have beeon posted for this weekly.
    public let numberOfRants: Int
    
    public var id: Int { week }
    
    public init(week: Int, topic: String, formattedDate: String, numberOfRants: Int) {
        self.week = week
        self.topic = topic
        self.formattedDate = formattedDate
        self.numberOfRants = numberOfRants
    }
}

extension Weekly {
    struct CodingData: Codable {
        let week: Int
        let prompt: String
        let date: String
        let num_rants: Int
        
        struct List: Codable {
            let weeks: [CodingData]
        }
    }
}

extension Weekly.CodingData {
    var decoded: Weekly {
        .init(
            week: week,
            topic: prompt,
            formattedDate: date,
            numberOfRants: num_rants
        )
    }
}
