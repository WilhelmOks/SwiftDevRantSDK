import Foundation

public struct AuthToken: Hashable {
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

extension AuthToken {
    struct CodingData: Codable {
        struct Container: Codable {
            let auth_token: AuthToken.CodingData
        }
        
        let id: Int
        let key: String
        let expire_time: Int
        let user_id: Int
    }
}

extension AuthToken.CodingData {
    var decoded: AuthToken {
        .init(
            id: id,
            key: key,
            expireTime: Date(timeIntervalSince1970: TimeInterval(expire_time)),
            userId: user_id
        )
    }
}
