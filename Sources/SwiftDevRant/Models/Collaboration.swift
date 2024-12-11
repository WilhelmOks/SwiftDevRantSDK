public struct Collaboration: Hashable {
    public enum Kind: Int {
        case openSourceIdea = 1
        case existingOpenSourceProject = 2
        case projectIdea = 3
        case existingProject = 4
    }
    
    public let kind: Kind?
    public let kindDescription: String
    public let description: String
    public let techStack: String
    public let teamSize: String
    public let url: String
    
    public init(kind: Kind?, kindDescription: String, description: String, techStack: String, teamSize: String, url: String) {
        self.kind = kind
        self.kindDescription = kindDescription
        self.description = description
        self.techStack = techStack
        self.teamSize = teamSize
        self.url = url
    }
}
