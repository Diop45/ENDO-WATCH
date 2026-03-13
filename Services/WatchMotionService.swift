import Foundation
import CoreMotion
import HealthKit

@Observable
class WatchMotionService {
    var currentActivity: HKWorkoutActivityType = .other

    private let motionManager = CMMotionActivityManager()

    // MARK: - Lifecycle

    func start() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        motionManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity else { return }
            self?.currentActivity = Self.mapActivity(activity)
        }
    }

    func stop() {
        motionManager.stopActivityUpdates()
    }

    // MARK: - Icon

    func iconName(for activityType: HKWorkoutActivityType) -> String {
        switch activityType {
        case .walking:          return "figure.walk"
        case .running:          return "figure.run"
        case .cycling:          return "figure.outdoor.cycle"
        case .swimming:         return "figure.open.water.swim"
        default:                return "figure.stand"
        }
    }

    // MARK: - Private

    private static func mapActivity(_ activity: CMMotionActivity) -> HKWorkoutActivityType {
        if activity.running  { return .running }
        if activity.cycling  { return .cycling }
        if activity.walking  { return .walking }
        return .other
    }
}
