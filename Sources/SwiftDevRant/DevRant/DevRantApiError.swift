/// Represents an error coming directly from the devrant API.
public struct DevRantApiError: Swift.Error {
    let message: String
}

public extension DevRantApiError {
    struct CodingData: Decodable, Swift.Error {
        let error: String
    }
}

public extension DevRantApiError.CodingData {
    var decoded: DevRantApiError {
        .init(message: error)
    }
}
