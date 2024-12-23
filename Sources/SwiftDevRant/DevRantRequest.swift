import Foundation
import KreeRequest

public struct DevRantRequest {
    let request: KreeRequest
    let backend = DevRantBackend()
    
    public init(requestLogger: Logger) {
        self.request = KreeRequest(encoder: .devRant, decoder: .devRant, logger: requestLogger)
    }
    
    private func makeConfig(_ method: KreeRequest.Method, path: String, urlParameters: [String: String] = [:], headers: [String: String] = [:], token: AuthToken? = nil) -> KreeRequest.Config {
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
    
    private func makeMultipartConfig(_ method: KreeRequest.Method, path: String, parameters: [String: String] = [:], boundary: String, headers: [String: String] = [:], token: AuthToken? = nil) -> KreeRequest.Config {
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
    
    /// For endpoints with the POST method in the devRant API the url parameters need to be passed as a string in the http body rather than in the URL.
    /// The url encoding works but it might also work with other encodings like json or multipart form data.
    private func stringBody(fromUrlParameters urlParameters: [String: String]) -> String {
        String(KreeRequest.urlEncodedQueryString(from: urlParameters).dropFirst()) // dropping the first character "?"
    }
}

public extension DevRantRequest {
    func logIn(username: String, password: String) async throws -> AuthToken {
        var parameters: [String: String] = [:]
        parameters["app"] = "3"
        parameters["username"] = username
        parameters["password"] = password
        
        let config = makeConfig(.post, path: "users/auth-token")
        
        let body = stringBody(fromUrlParameters: parameters)
        
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
    func getRantFeed(token: AuthToken, sort: RantFeed.Sort = .algorithm, limit: Int = 20, skip: Int, sessionHash: String?) async throws -> RantFeed {
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
    func getWeeklies(token: AuthToken) async throws -> [Weekly] {
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
    func getWeeklyRants(token: AuthToken, week: Int?, limit: Int = 20, skip: Int) async throws -> RantFeed {
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
    func getNotificationFeed(token: AuthToken, lastChecked: Date?, category: NotificationFeed.Category) async throws -> NotificationFeed {
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
    func getRant(token: AuthToken, rantId: Int, lastCommentId: Int? = nil) async throws -> (rant: Rant, comments: [Comment]) {
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
    func getComment(token: AuthToken, commentId: Int) async throws -> Comment {
        let config = makeConfig(.get, path: "comments/\(commentId)", token: token)
        
        let response: Comment.CodingData = try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
        
        return response.decoded
    }
    
    /// Gets the id of a user.
    ///
    /// - Parameters:
    ///    - username: The username of the user.
    func getUserId(username: String) async throws -> Int {
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
    func getProfile(token: AuthToken, userId: Int, contentType: Profile.ContentType, skip: Int) async throws -> Profile {
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
    func voteOnRant(token: AuthToken, rantId: Int, vote: VoteState, downvoteReason: DownvoteReason = .notForMe) async throws -> Rant {
        let config = makeConfig(.post, path: "devrant/rants/\(rantId)/vote", token: token)
        
        var parameters = config.urlParameters

        parameters["vote"] = String(vote.rawValue)
        
        if vote == .downvoted {
            parameters["reason"] = String(downvoteReason.rawValue)
        }
        
        let body = stringBody(fromUrlParameters: parameters)
        
        struct Response: Codable {
            let rant: Rant.CodingData
        }
        
        let response: Response = try await request.requestJson(config: config, string: body, apiError: DevRantApiError.CodingData.self)
        
        return response.rant.decoded
    }
    
    /// Votes on a comment.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - commentId: The id of the comment.
    ///    - vote: The vote for this comment.
    func voteOnComment(token: AuthToken, commentId: Int, vote: VoteState, downvoteReason: DownvoteReason = .notForMe) async throws -> Comment {
        let config = makeConfig(.post, path: "comments/\(commentId)/vote", token: token)
        
        var parameters = config.urlParameters

        parameters["vote"] = String(vote.rawValue)
        
        if vote == .downvoted {
            parameters["reason"] = String(downvoteReason.rawValue)
        }
        
        let body = stringBody(fromUrlParameters: parameters)
        
        struct Response: Decodable {
            let comment: Comment.CodingData
        }
        
        let response: Response = try await request.requestJson(config: config, string: body, apiError: DevRantApiError.CodingData.self)
        
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
    func editUserProfile(token: AuthToken, about: String, skills: String, github: String, location: String, website: String) async throws {
        let config = makeConfig(.post, path: "users/me/edit-profile", token: token)
        
        var parameters = config.urlParameters

        parameters["profile_about"] = about
        parameters["profile_skills"] = skills
        parameters["profile_github"] = github
        parameters["profile_location"] = location
        parameters["profile_website"] = website
        
        let body = stringBody(fromUrlParameters: parameters)
        
        try await request.requestJson(config: config, string: body, apiError: DevRantApiError.CodingData.self)
    }
    
    /// Creates and posts a rant.
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
    func postRant(token: AuthToken, kind: Rant.Kind, text: String, tags: String, image: Data?, imageConversion: [ImageDataConverter] = [.unsupportedToJpeg]) async throws -> Int {
        let boundary = UUID().uuidString
        
        let config = makeMultipartConfig(.post, path: "devrant/rants", boundary: boundary, token: token)
        
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
    
    /// Deletes a rant.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - rantId: The id of the rant.
    func deleteRant(token: AuthToken, rantId: Int) async throws {
        let config = makeConfig(.delete, path: "devrant/rants/\(rantId)", token: token)
        
        try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
    }
    
    /// Sets or unsets a rant as a favorite.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - rantId: The id of the rant.
    ///    - favorite: `true` sets the rant as favorite and `false` sets it as not favorite.
    func favoriteRant(token: AuthToken, rantId: Int, favorite: Bool) async throws {
        let favoritePath = favorite ? "favorite" : "unfavorite"
        
        let config = makeConfig(.post, path: "devrant/rants/\(rantId)/\(favoritePath)", token: token)
        
        let parameters = config.urlParameters
        
        let body = stringBody(fromUrlParameters: parameters)
        
        try await request.requestJson(config: config, string: body, apiError: DevRantApiError.CodingData.self)
    }
    
    /// Edits a posted rant.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - rantId: The id of the rant.
    ///    - kind: The type of the rant.
    ///    - text: The text content of the rant.
    ///    - tags: The rants's associated tags.
    ///    - image: An image to attach to the rant.
    func editRant(token: AuthToken, rantId: Int, kind: Rant.Kind, text: String, tags: String, image: Data?, imageConversion: [ImageDataConverter] = [.unsupportedToJpeg]) async throws {
        let boundary = UUID().uuidString
        
        let config = makeMultipartConfig(.post, path: "devrant/rants/\(rantId)", boundary: boundary, token: token)
        
        var parameters = config.urlParameters

        parameters["rant"] = text
        parameters["tags"] = tags
        parameters["type"] = String(kind.rawValue)
        
        let convertedImage = image.flatMap { imageConversion.convert($0) }
        
        let bodyData = multipartBody(parameters: parameters, boundary: boundary, imageData: convertedImage)
        
        try await request.requestJson(config: config, data: bodyData, apiError: DevRantApiError.CodingData.self)
    }
    
    /// Creates and posts a comment for a specific rant.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - rantId: The id of the rant that this comment should be posted for.
    ///    - text: The text content of the comment.
    ///    - image: An image to attach to the comment.
    func postComment(token: AuthToken, rantId: Int, text: String, image: Data?, imageConversion: [ImageDataConverter] = [.unsupportedToJpeg]) async throws {
        let boundary = UUID().uuidString
        
        let config = makeMultipartConfig(.post, path: "devrant/rants/\(rantId)/comments", boundary: boundary, token: token)
        
        var parameters = config.urlParameters

        parameters["comment"] = text
        
        let convertedImage = image.flatMap { imageConversion.convert($0) }
        
        let bodyData = multipartBody(parameters: parameters, boundary: boundary, imageData: convertedImage)
        
        try await request.requestJson(config: config, data: bodyData, apiError: DevRantApiError.CodingData.self)
    }
    
    /// Edits a posted comment.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - commentId: The id of the comment.
    ///    - text: The text content of the comment.
    ///    - image: An image to attach to the comment.
    func editComment(token: AuthToken, commentId: Int, text: String, image: Data?, imageConversion: [ImageDataConverter] = [.unsupportedToJpeg]) async throws {
        let boundary = UUID().uuidString
        
        let config = makeMultipartConfig(.post, path: "comments/\(commentId)", boundary: boundary, token: token)
        
        var parameters = config.urlParameters

        parameters["comment"] = text
        
        let convertedImage = image.flatMap { imageConversion.convert($0) }
        
        let bodyData = multipartBody(parameters: parameters, boundary: boundary, imageData: convertedImage)
        
        try await request.requestJson(config: config, data: bodyData, apiError: DevRantApiError.CodingData.self)
    }
    
    /// Deletes a comment.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - commentId: The id of the comment.
    func deleteComment(token: AuthToken, commentId: Int) async throws {
        let config = makeConfig(.delete, path: "comments/\(commentId)", token: token)
        
        try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
    }
    
    /// Marks all notifications as read.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    func markAllNotificationsAsRead(token: AuthToken) async throws {
        let config = makeConfig(.delete, path: "users/me/notif-feed", token: token)
        
        try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
    }
    
    /// Subscribes to a user.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - userId: The id of the user to subscribe to.
    func subscribeToUser(token: AuthToken, userId: Int) async throws {
        let config = makeConfig(.post, path: "users/\(userId)/subscribe", token: token)
        
        let parameters = config.urlParameters
        
        let body = stringBody(fromUrlParameters: parameters)
        
        try await request.requestJson(config: config, string: body, apiError: DevRantApiError.CodingData.self)
    }
    
    /// Unsubscribes from a user.
    ///
    /// - Parameters:
    ///    - token: The token from the `logIn` call response.
    ///    - userId: The id of the user to unsubscribe from.
    func unsubscribeFromUser(token: AuthToken, userId: Int) async throws {
        let config = makeConfig(.delete, path: "users/\(userId)/subscribe", token: token)
        
        try await request.requestJson(config: config, apiError: DevRantApiError.CodingData.self)
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: false)
        append(data!)
    }
}
