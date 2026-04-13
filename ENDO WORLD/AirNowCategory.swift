import Foundation

struct AirNowCategory: Codable, Sendable {
    let number: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case number = "Number"
        case name = "Name"
    }
}
