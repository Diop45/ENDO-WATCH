import Foundation

struct NOAAHumidity: Codable, Sendable {
    let unitCode: String
    let value: Int?

    enum CodingKeys: String, CodingKey {
        case unitCode = "unitCode"
        case value = "value"
    }
}
