import Foundation

struct CDCPlacesRecord: Codable, Sendable {
    let stateDesc: String?
    let countyName: String?
    let locationName: String?
    let datavaluetype: String?
    let dataValue: String?
    let measure: String?
    let measureid: String?
    let geolocation: CDCGeolocation?

    var dataValueDouble: Double? {
        guard let s = dataValue else { return nil }
        return Double(s)
    }

    enum CodingKeys: String, CodingKey {
        case stateDesc = "statedesc"
        case countyName = "countyname"
        case locationName = "locationname"
        case datavaluetype
        case dataValue = "data_value"
        case measure
        case measureid
        case geolocation
    }
}
