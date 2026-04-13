import Foundation

struct NOAAAlertProperties: Codable, Sendable {
    let event: String
    let severity: String
    let headline: String?
    let description: String?
    let effective: String?
    let expires: String?
}
