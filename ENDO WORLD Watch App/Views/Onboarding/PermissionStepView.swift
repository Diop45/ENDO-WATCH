import SwiftUI

struct PermissionStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    let permission: Permission

    enum Permission {
        case location
        case health
        case notifications
    }

    private var iconName: String {
        switch permission {
        case .location: return "location.circle.fill"
        case .health: return "heart.fill"
        case .notifications: return "bell.badge.fill"
        }
    }

    private var iconColor: Color {
        switch permission {
        case .location: return Color(hex: "#34C759")
        case .health: return Color(hex: "#FF3B3B")
        case .notifications: return Color(hex: "#FF9F0A")
        }
    }

    private var title: String {
        switch permission {
        case .location: return "Allow Location"
        case .health: return "Connect Health"
        case .notifications: return "Zone Alerts"
        }
    }

    private var bodyText: String {
        switch permission {
        case .location: return "Used only while the app is open.\nRounded to ~110 m for privacy."
        case .health: return "Heart rate, HRV, SpO₂, noise, VO₂ max.\nRead-only. Never uploaded."
        case .notifications: return "Get a tap when your environment score changes.\nTurn off anytime in Settings."
        }
    }

    private var granted: Bool {
        switch permission {
        case .location: return viewModel.locationGranted
        case .health: return viewModel.healthGranted
        case .notifications: return viewModel.notifGranted
        }
    }

    private var denied: Bool {
        switch permission {
        case .location: return viewModel.locationRequested && !viewModel.locationGranted
        case .health: return viewModel.healthRequested && !viewModel.healthGranted
        case .notifications: return viewModel.notifRequested && !viewModel.notifGranted
        }
    }

    private var buttonTitle: String {
        if granted {
            switch permission {
            case .location: return "Location On ✓"
            case .health: return "Health Connected ✓"
            case .notifications: return "Alerts On ✓"
            }
        }
        if denied { return "Continue Anyway" }
        switch permission {
        case .location: return "Allow Location"
        case .health: return "Connect Health"
        case .notifications: return "Allow Alerts"
        }
    }

    private var stepIndex: Int {
        switch permission {
        case .location: return 2
        case .health: return 3
        case .notifications: return 4
        }
    }

    var body: some View {
        OnboardingCardShell(
            content: {
                VStack(spacing: 12) {
                    Image(systemName: iconName)
                        .font(.system(size: 28))
                        .foregroundStyle(iconColor)
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    Text(bodyText)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    if denied {
                        Text("You can change this in Settings → Privacy")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
            },
            buttonTitle: buttonTitle,
            buttonAction: buttonAction,
            progressSteps: 6,
            currentStepIndex: stepIndex,
            buttonDisabled: granted
        )
    }

    private func buttonAction() {
        if granted || denied {
            viewModel.advance()
        } else {
            Task {
                switch permission {
                case .location: await viewModel.requestLocation()
                case .health: await viewModel.requestHealth()
                case .notifications: await viewModel.requestNotifications()
                }
            }
        }
    }
}
