import Foundation

enum EndoTab: Int, Hashable, CaseIterable {
    case map = 0
    case today = 1
    case vitals = 2
    case health = 3

    var title: String {
        switch self {
        case .map: "Map"
        case .today: "Today"
        case .vitals: "Vitals"
        case .health: "Health"
        }
    }

    var systemImage: String {
        switch self {
        case .map: "map"
        case .today: "sun.max"
        case .vitals: "waveform.path.ecg"
        case .health: "heart.text.square"
        }
    }
}
