public struct AuthToken: Codable, Hashable {
    public struct Container: Codable {
        public let auth_token: AuthToken
    }
    
    public let id: Int
    public let key: String
    public let expire_time: Int
    public let user_id: Int
}
