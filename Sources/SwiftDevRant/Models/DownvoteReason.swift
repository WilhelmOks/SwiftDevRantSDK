/// Represents the reason for downvoting.
public enum DownvoteReason: Int, Hashable, Sendable {
    case notForMe = 0
    case repost = 1
    case offensiveOrSpam = 2
}
