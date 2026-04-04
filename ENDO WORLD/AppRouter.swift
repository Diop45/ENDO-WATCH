import Foundation

@Observable @MainActor
final class AppRouter {
    var onboardingComplete: Bool = false
    var selectedTab: ENDOTab = .today

    enum ENDOTab: Int, CaseIterable {
        case today = 0
        case vitals = 1
        case map = 2
        case health = 3

        var label: String {
            switch self {
            case .today: "Today"
            case .vitals: "Vitals"
            case .map: "Map"
            case .health: "Health"
            }
        }

        var icon: String {
            switch self {
            case .today: "house.fill"
            case .vitals: "waveform.path.ecg"
            case .map: "map.fill"
            case .health: "chart.bar.fill"
            }
        }
    }
}
