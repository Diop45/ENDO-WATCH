import Foundation

/// Role tier — earned through mutual scans.
enum AnonUserRole: String {
    case scout = "Scout"
    case mapper = "Mapper"

    var isMapper: Bool {
        self == .mapper
    }
}
