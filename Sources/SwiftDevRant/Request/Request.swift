import Foundation

public struct Request {
    public enum Error<ApiError: Decodable & Sendable>: Swift.Error, CustomStringConvertible {
        case notHttpResponse
        case notFound
        case noInternet
        case apiError(_ error: ApiError)
        case generalError
        
        public var description: String {
            switch self {
            case .notHttpResponse: "Response is not HTTP"
            case .notFound: "Not found"
            case .noInternet: "No internet connection"
            case .apiError(error: let error): "\(error)"
            case .generalError: "General error"
            }
        }
    }
    
    public struct EmptyError: Decodable, Swift.Error {
        
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
    
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let session: URLSession
    let logger: Logger?
    
    public init(encoder: JSONEncoder, decoder: JSONDecoder, session: URLSession = .init(configuration: .ephemeral), logger: Logger? = nil) {
        self.encoder = encoder
        self.decoder = decoder
        self.session = session
        self.logger = logger
    }
    
    private func makeURLRequest(config: Config, body: Data?) -> URLRequest {
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
    
    private func urlEncodedQueryString(from query: [String: String]) -> String {
        guard !query.isEmpty else { return "" }
        var components = URLComponents()
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        let absoluteString = components.url?.absoluteString ?? ""
        let plusCorrection = absoluteString.replacingOccurrences(of: "+", with: "%2b")
        return plusCorrection
    }
    
    @discardableResult private func requestData<ApiError: Decodable>(urlRequest: URLRequest, apiError: ApiError.Type = EmptyError.self) async throws(Error<ApiError>) -> (data: Data, headers: [AnyHashable: Any]) {
        do {
            let response = try await session.data(for: urlRequest)
            
            if let httpResponse = response.1 as? HTTPURLResponse {
                let data = response.0
                
                if let logger {
                    let logInputString = urlRequest.httpBody.flatMap { jsonString(data: $0, prettyPrinted: true) } ?? "(none)"
                    let logOutputString = !data.isEmpty ? jsonString(data: data, prettyPrinted: true) ?? "-" : "(none)"
                    logger.log("\(urlRequest.httpMethod?.uppercased() ?? "?") \(urlRequest.url?.absoluteString ?? "")\nbody: \(logInputString)\nresponse: \(logOutputString)")
                }
                
                if (200..<300).contains(httpResponse.statusCode) {
                    return (data, httpResponse.allHeaderFields)
                } else if httpResponse.statusCode == 404 {
                    throw Error<ApiError>.notFound
                } else {
                    throw Error<ApiError>.apiError(try decoder.decode(apiError, from: data))
                }
            } else {
                throw Error<ApiError>.notHttpResponse
            }
        } catch {
            if let error = error as? URLError, error.code == .notConnectedToInternet {
                throw Error<ApiError>.noInternet
            } else {
                throw Error<ApiError>.generalError
            }
        }
    }
    
    /// JSON Data to String converter for printing/logging purposes
    private func jsonString(data: Data, prettyPrinted: Bool) -> String? {
        do {
            let writingOptions: JSONSerialization.WritingOptions = prettyPrinted ? [.prettyPrinted] : []
            let decoded: Data?
            if String(data: data, encoding: .utf8) == "null" {
                decoded = nil
            } else if let string = String(data: data, encoding: .utf8), string.first == "\"", string.last == "\"" {
                decoded = data
            } else if let encodedDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                decoded = try JSONSerialization.data(withJSONObject: encodedDict, options: writingOptions)
            } else if let encodedArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                decoded = try JSONSerialization.data(withJSONObject: encodedArray, options: writingOptions)
            } else {
                decoded = nil
            }
            return decoded.flatMap { String(data: $0, encoding: .utf8) }
        } catch {
            print(error)
            return String(data: data, encoding: .utf8)
        }
    }
    
    // MARK: public
    
    public func requestJson<ApiError: Decodable>(config: Config, apiError: ApiError.Type = EmptyError.self) async throws(Error<ApiError>) {
        let urlRequest = makeURLRequest(config: config, body: nil)
        try await requestData(urlRequest: urlRequest, apiError: apiError)
    }
    
    public func requestJson<In: Encodable, ApiError: Decodable & Sendable>(config: Config, json: In, apiError: ApiError.Type = EmptyError.self) async throws {
        let inData = try encoder.encode(json)
        let urlRequest = makeURLRequest(config: config, body: inData)
        try await requestData(urlRequest: urlRequest, apiError: apiError)
    }
    
    public func requestJson<Out: Decodable, ApiError: Decodable & Sendable>(config: Config, apiError: ApiError.Type = EmptyError.self) async throws -> Out {
        let urlRequest = makeURLRequest(config: config, body: nil)
        let outData = try await requestData(urlRequest: urlRequest, apiError: apiError).data
        return try decoder.decode(Out.self, from: outData)
    }
    
    public func requestJson<In: Encodable, Out: Decodable, ApiError: Decodable & Sendable>(config: Config, json: In, apiError: ApiError.Type = EmptyError.self) async throws -> Out {
        let inData = try encoder.encode(json)
        let urlRequest = makeURLRequest(config: config, body: inData)
        let outData = try await requestData(urlRequest: urlRequest, apiError: apiError).data
        return try decoder.decode(Out.self, from: outData)
    }
}
