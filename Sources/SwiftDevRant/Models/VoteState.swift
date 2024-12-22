/// Represents the different kinds of votes that a rant or comment can have.
public enum VoteState: Int, Hashable, Sendable {
    /// A given ++ vote.
    case upvoted = 1
    
    /// No votes given.
    case unvoted = 0
    
    /// A given -- vote.
    case downvoted = -1
    
    /// Not able to vote (if the rant or comment belongs to the logged in user).
    case unvotable = -2
}
