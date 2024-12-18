import Foundation

public struct SwiftDevRant {
    let request: Request
    let backend = DevRantBackend()
    
    public init(requestLogger: Logger) {
        self.request = Request(encoder: .devRant, decoder: .devRant, logger: requestLogger)
    }
    
    func makeConfig(_ method: Request.Method, path: String, urlParameters: [String: String] = [:], headers: [String: String] = [:], token: AuthToken? = nil) -> Request.Config {
        var urlParameters = urlParameters
        urlParameters["app"] = "3"
        if let token {
            urlParameters["token_id"] = String(token.id)
            urlParameters["token_key"] = token.key
            urlParameters["user_id"] = String(token.userId)
        }
        
        var headers = headers
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        
        return .init(method: method, backend: backend, path: path, urlParameters: urlParameters, headers: headers)
    }
    
    public func logIn(username: String, password: String) async throws -> AuthToken {
        var parameters: [String: String] = [:]
        parameters["app"] = "3"
        parameters["username"] = username
        parameters["password"] = password
        
        let config = makeConfig(.post, path: "users/auth-token")
        
        // For the log in request the url encoded parameters are passed as a string in the http body instead of in the URL.
        let body = String(Request.urlEncodedQueryString(from: parameters).dropFirst()) // dropping the first character "?"
        
        let response: AuthToken.CodingData.Container = try await request.requestJson(config: config, string: body, apiError: DevRantApiError.CodingData.self)
        
        return response.auth_token.decoded
    }
    
    /// Gets a personalized feed of rants.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - limit: The number of rants to get for pagination.
    ///    - skip: How many rants to skip for pagination.
    ///    - sessionHash: Pass the session hash value from the last rant feed response or `nil` if calling for the first time.
    public func getRantFeed(token: AuthToken, sort: RantFeed.Sort = .algorithm, limit: Int = 20, skip: Int, sessionHash: String?) async throws -> RantFeed {
        var parameters: [String: String] = [:]
        
        parameters["sort"] = switch sort {
        case .algorithm: "algo"
        case .recent: "recent"
        case .top: "top"
        }
        
        switch sort {
        case .top(range: let range):
            parameters["range"] = switch range {
            case .day: "day"
            case .week: "week"
            case .month: "month"
            case .all: "all"
            }
        default:
            break
        }
        
        parameters["limit"] = String(limit)
        parameters["skip"] = String(skip)
        parameters["prev_set"] = sessionHash
        
        parameters["plat"] = "1" // I don't know wtf that is.
        parameters["nari"] = "1" // I don't know wtf that is.
        
        let config = makeConfig(.get, path: "devrant/rants", urlParameters: parameters)
        
        let response: RantFeed.CodingData = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.decoded
    }
    
    /// Gets all weeklies as a list.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    public func getWeeklies(token: AuthToken) async throws -> [Weekly] {
        let config = makeConfig(.get, path: "devrant/weekly-list")
        
        let response: Weekly.CodingData.List = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.weeks.map(\.decoded)
    }
    
    /// Gets a specific week's weekly rants.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - week: The number of the week. Pass `nil` to get the latest week's rants.
    ///    - limit: The number of rants for pagination.
    ///    - skip: How many rants to skip for pagination.
    public func getWeeklyRants(token: AuthToken, week: Int?, limit: Int = 20, skip: Int) async throws -> RantFeed {
        var parameters: [String: String] = [:]
        
        parameters["week"] = week.flatMap { String($0) }
        parameters["limit"] = String(limit)
        parameters["skip"] = String(skip)
        
        //parameters["sort"] = "algo" //TODO: This seems wrong. Check if this is needed or not.
        
        let config = makeConfig(.get, path: "devrant/weekly-rants", urlParameters: parameters)
        
        let response: RantFeed.CodingData = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.decoded
    }
    
    /// Gets the list of notifications and numbers for each notification type.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - lastChecked: Pass the value from the last response or `nil`.
    public func getNotificationFeed(token: AuthToken, lastChecked: Date?, category: NotificationFeed.Category) async throws -> NotificationFeed {
        var parameters: [String: String] = [:]
        
        parameters["last_time"] = lastChecked.flatMap { String(Int($0.timeIntervalSince1970)) } ?? "0"
        parameters["ext_prof"] = "1" // I don't know wtf that is.
        
        let config = makeConfig(.get, path: "users/me/notif-feed\(category.rawValue)", urlParameters: parameters)
        
        let response: NotificationFeed.CodingData.Container = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.data.decoded
    }
    
    /// Gets a single rant and its comments.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - rantId: The id of the rant.
    ///    - lastCommentId: Only fetch the comments which were posted after the one corresponding to this id. Pass `nil` to get all comments.
    public func getRant(token: AuthToken, rantId: Int, lastCommentId: Int? = nil) async throws -> (rant: Rant, comments: [Comment]) {
        var parameters: [String: String] = [:]

        parameters["last_comment_id"] = lastCommentId.flatMap { String($0) }
        //parameters["ver"] = "1.17.0.4" //TODO: check if this is needed
        
        let config = makeConfig(.get, path: "devrant/rants/\(rantId)", urlParameters: parameters)
        
        struct Response: Codable {
            let rant: Rant.CodingData
            let comments: [Comment.CodingData]?
        }
        
        let response: Response = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return (rant: response.rant.decoded, comments: response.comments?.map(\.decoded) ?? [])
    }
}
