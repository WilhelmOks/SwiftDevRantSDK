enum StringOrIntDecodable: Decodable {
    case string(String)
    case int(Int)
    
    init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }
        
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Expected String or Int"))
    }
    
    func decodedAsString() -> String {
        switch self {
        case .int(let integer): String(integer)
        case .string(let string): string
        }
    }
}
