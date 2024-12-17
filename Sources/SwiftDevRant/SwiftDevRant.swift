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
    
    /// Get all weeklies as a list.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    public func getWeeklies(token: AuthToken) async throws -> [Weekly] {
        let config = makeConfig(.get, path: "devrant/weekly-list")
        
        let response: Weekly.CodingData.List = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.weeks.map(\.decoded)
    }
}
