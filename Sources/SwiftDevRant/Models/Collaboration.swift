public struct Collaboration: Hashable {
    public let type: String //TODO: check if this is a kind of enum or some arbitrary text entered by the user.
    public let description: String
    public let techStack: String
    public let teamSize: String
    public let url: String
    
    public init(type: String, description: String, techStack: String, teamSize: String, url: String) {
        self.type = type
        self.description = description
        self.techStack = techStack
        self.teamSize = teamSize
        self.url = url
    }
}
