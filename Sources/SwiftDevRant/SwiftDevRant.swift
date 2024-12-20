import Foundation

public struct SwiftDevRant {
    let request: Request
    let backend = DevRantBackend()
    
    public init(requestLogger: Logger) {
        self.request = Request(encoder: .devRant, decoder: .devRant, logger: requestLogger)
    }
    
    private func makeConfig(_ method: Request.Method, path: String, urlParameters: [String: String] = [:], headers: [String: String] = [:], token: AuthToken? = nil) -> Request.Config {
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
    
    private func makeMultipartConfig(_ method: Request.Method, path: String, parameters: [String: String] = [:], boundary: String, headers: [String: String] = [:], token: AuthToken? = nil) -> Request.Config {
        var parameters = parameters
        parameters["app"] = "3"
        
        if let token {
            parameters["token_id"] = String(token.id)
            parameters["token_key"] = token.key
            parameters["user_id"] = String(token.userId)
        }
        
        var headers = headers
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        
        return .init(method: method, backend: backend, path: path, urlParameters: parameters, headers: headers)
    }
    
    private func multipartBody(parameters: [String: String], boundary: String, imageData: Data?) -> Data {
        var body = Data()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        if let imageData {
            //TODO: the image is not always jpeg. not sure if it matters here.
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpeg\"\r\n")
            body.appendString("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.appendString("\r\n")
        }
        
        body.appendString("--".appending(boundary.appending("--")))
        
        return body
    }
}

public extension SwiftDevRant {
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
        
        let config = makeConfig(.get, path: "devrant/rants", urlParameters: parameters, token: token)
        
        let response: RantFeed.CodingData = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.decoded
    }
    
    /// Gets all weeklies as a list.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    public func getWeeklies(token: AuthToken) async throws -> [Weekly] {
        let config = makeConfig(.get, path: "devrant/weekly-list", token: token)
        
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
        
        let config = makeConfig(.get, path: "devrant/weekly-rants", urlParameters: parameters, token: token)
        
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
        
        let config = makeConfig(.get, path: "users/me/notif-feed\(category.rawValue)", urlParameters: parameters, token: token)
        
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
        
        let config = makeConfig(.get, path: "devrant/rants/\(rantId)", urlParameters: parameters, token: token)
        
        struct Response: Codable {
            let rant: Rant.CodingData
            let comments: [Comment.CodingData]?
        }
        
        let response: Response = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return (rant: response.rant.decoded, comments: response.comments?.map(\.decoded) ?? [])
    }
    
    /// Gets a single comment.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - commentId: The id of the comment.
    public func getCommentFromID(token: AuthToken, commentId: Int) async throws -> Comment {
        let config = makeConfig(.get, path: "comments/\(commentId)", token: token)
        
        let response: Comment.CodingData = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.decoded
    }
    
    /// Gets the id of a user.
    ///
    /// - Parameters:
    ///    - username: The username of the user.
    public func getUserId(username: String) async throws -> Int {
        var parameters: [String: String] = [:]

        parameters["username"] = username
        
        let config = makeConfig(.get, path: "get-user-id", urlParameters: parameters)
        
        struct Response: Decodable {
            let user_id: Int
        }
        
        let response: Response = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.user_id
    }
    
    /// Gets a user's profile data.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - userId: The id of the user.
    ///    - contentType: The type of content created by the user to be fetched.
    ///    - skip: The number of content items to skip for pagination.
    public func getProfileFromID(token: AuthToken, userId: Int, contentType: Profile.ContentType, skip: Int) async throws -> Profile {
        var parameters: [String: String] = [:]

        parameters["skip"] = String(skip)
        parameters["content"] = contentType.rawValue
        
        let config = makeConfig(.get, path: "users/\(userId)", urlParameters: parameters, token: token)
        
        let response: Profile.CodingData = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.decoded
    }
    
    /// Votes on a rant.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - rantId: The id of the rant.
    ///    - vote: The vote for this rant.
    public func voteOnRant(token: AuthToken, rantId: Int, vote: VoteState) async throws -> Rant { //TODO: add downvote reason
        var parameters: [String: String] = [:]

        parameters["vote"] = String(vote.rawValue)
        
        let config = makeConfig(.post, path: "devrant/rants/\(rantId)/vote", urlParameters: parameters, token: token)
        
        struct Response: Codable {
            let rant: Rant.CodingData
            //let comments: [Comment.CodingData]? //probably not needed
        }
        
        let response: Response = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.rant.decoded
    }
    
    /// Votes on a comment.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - commentId: The id of the comment.
    ///    - vote: The vote for this comment.
    public func voteOnComment(token: AuthToken, commentId: Int, vote: VoteState) async throws -> Comment {
        var parameters: [String: String] = [:]

        parameters["vote"] = String(vote.rawValue)
        
        let config = makeConfig(.post, path: "comments/\(commentId)/vote", urlParameters: parameters, token: token)
        
        struct Response: Decodable {
            let comment: Comment.CodingData
        }
        
        let response: Response = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.comment.decoded
    }
    
    /// Updates the user profile.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - about: The user's about text.
    ///    - skills: The user's list of skills.
    ///    - github: The user's GitHub link.
    ///    - location: The user's geographic location.
    ///    - website: The user's personal website.
    public func editUserProfile(token: AuthToken, about: String, skills: String, github: String, location: String, website: String) async throws {
        var parameters: [String: String] = [:]

        parameters["profile_about"] = about
        parameters["profile_skills"] = skills
        parameters["profile_github"] = github
        parameters["profile_location"] = location
        parameters["profile_website"] = website
        
        let config = makeConfig(.post, path: "users/me/edit-profile", urlParameters: parameters, token: token)
        
        try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
    }
    
    /// Posts a rant.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - kind: The type of rant.
    ///    - text: The text content of the rant.
    ///    - tags: The rant's associated tags.
    ///    - image: An image to attach to the rant.
    ///    - imageConversion: The image conversion methods for unsupported image formats.
    /// - Returns:
    ///    The id of the posted rant.
    public func postRant(token: AuthToken, kind: Rant.Kind, text: String, tags: String, image: Data?, imageConversion: [ImageDataConverter] = [.unsupportedToJpeg]) async throws -> Int {
        let boundary = UUID().uuidString
        
        let config = makeMultipartConfig(.post, path: "devrant/rants", boundary: boundary)
        
        var parameters = config.urlParameters

        parameters["content"] = text
        parameters["tags"] = tags
        parameters["type"] = String(kind.rawValue)
        
        let convertedImage = image.flatMap { imageConversion.convert($0) }
        
        let bodyData = multipartBody(parameters: parameters, boundary: boundary, imageData: convertedImage)
        
        struct Response: Decodable {
            let rant_id: Int
        }
        
        let response: Response = try await request.requestJson(config: config, data: bodyData, apiError: DevRantApiError.CodingData.self)
        
        return response.rant_id
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: false)
        append(data!)
    }
}
