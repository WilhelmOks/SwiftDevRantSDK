import Foundation

public struct AuthToken: Hashable, Sendable {
    public let id: Int
    public let key: String
    public let expireTime: Date
    public let userId: Int
    
    public init(id: Int, key: String, expireTime: Date, userId: Int) {
        self.id = id
        self.key = key
        self.expireTime = expireTime
        self.userId = userId
    }
    
    public var isExpired: Bool {
        expireTime < Date()
    }
}

public extension AuthToken {
    public struct CodingData: Codable {
        public struct Container: Codable {
            let auth_token: AuthToken.CodingData
        }
        
        public let id: Int
        public let key: String
        public let expire_time: Int
        public let user_id: Int
    }
}

public extension AuthToken.CodingData {
    public var decoded: AuthToken {
        .init(
            id: id,
            key: key,
            expireTime: Date(timeIntervalSince1970: TimeInterval(expire_time)),
            userId: user_id
        )
    }
}

public extension AuthToken {
    public var encoded: AuthToken.CodingData {
        .init(
            id: id,
            key: key,
            expire_time: Int(expireTime.timeIntervalSince1970),
            user_id: userId
        )
    }
}
