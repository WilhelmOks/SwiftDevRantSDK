import Foundation

public struct Request {
    public enum Error<ApiError: Decodable & Sendable>: Swift.Error, CustomStringConvertible {
        case notHttpResponse
        case notFound
        case apiError(_ error: ApiError)
        case generalError
        
        public var description: String {
            switch self {
            case .notHttpResponse: "response is not HTTP"
            case .notFound: "Not found"
            case .apiError(error: let error): "\(error)"
            case .generalError: "General error"
            }
        }
    }
    
    struct EmptyError: Decodable {
        
    }
    
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    public struct Config {
        let method: Method
        let backend: Backend
        let path: String
        var urlParameters: [String: String] = [:]
        var headers: [String: String] = [:]
    }
    
    var session = URLSession(configuration: .ephemeral)
    
    func makeURLRequest(config: Config, body: Data?) -> URLRequest {
        let urlQuery = urlEncodedQueryString(from: config.urlParameters)
        guard let url = URL(string: config.backend.baseURL + config.path + urlQuery) else {
            fatalError("Couldn't create a URL")
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        urlRequest.httpMethod = config.method.rawValue
        urlRequest.httpBody = body
        config.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        return urlRequest
    }
    
    func urlEncodedQueryString(from query: [String: String]) -> String {
        guard !query.isEmpty else { return "" }
        var components = URLComponents()
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        let absoluteString = components.url?.absoluteString ?? ""
        let plusCorrection = absoluteString.replacingOccurrences(of: "+", with: "%2b")
        return plusCorrection
    }
}
