public struct Collaboration: Hashable {
    public let type: String //TODO: check if this is a kind of enum or some arbitrary text entered by the user.
    public let description: String
    public let techStack: String
    public let teamSize: String
    public let url: String
}
