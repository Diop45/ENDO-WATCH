import Foundation
import Observation

@Observable @MainActor
final class TabRouter {
    var selected: EndoTab = .map

    func openToday() {
        selected = .today
    }
}
