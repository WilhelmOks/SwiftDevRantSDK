enum StringOrObjectDecodable<T: Decodable>: Decodable {
    case string(String)
    case object(T)
    
    init(from decoder: Decoder) throws {
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        
        if let object = try? decoder.singleValueContainer().decode(T.self) {
            self = .object(object)
            return
        }
        
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Expected String or Object \(T.self)"))
    }
    
    func decodedAsObject() -> T? {
        switch self {
        case .object(let object): object
        case .string(let string): nil
        }
    }
}
