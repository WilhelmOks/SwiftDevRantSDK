public extension Rant {
    enum Kind: Int, Sendable {
        case rant = 1
        case collaboration = 2
        case meme = 3
        case question = 4
        case devRant = 5
        case random = 6
        //case undefined = 7 // Not available anymore in the official app
    }
}
