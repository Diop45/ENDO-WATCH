import Foundation

struct NOAAAlertResponse: Codable, Sendable {
    let features: [NOAAAlertFeature]
}
