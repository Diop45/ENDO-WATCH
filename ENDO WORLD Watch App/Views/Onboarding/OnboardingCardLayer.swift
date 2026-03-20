import SwiftUI

struct OnboardingCardLayer: View {
    @Bindable var viewModel: OnboardingViewModel
    var onTriggerZoom: () -> Void

    var body: some View {
        Group {
            switch viewModel.step {
            case .globe:
                Color.clear
            case .welcome:
                welcomeCard
            case .whyItMatters:
                whyItMattersCard
            case .locationPerm:
                PermissionStepView(
                    viewModel: viewModel,
                    permission: .location
                )
            case .healthPerm:
                PermissionStepView(
                    viewModel: viewModel,
                    permission: .health
                )
            case .notifPerm:
                PermissionStepView(
                    viewModel: viewModel,
                    permission: .notifications
                )
            case .privacyPledge:
                PrivacyPledgeView(viewModel: viewModel)
            case .allSet:
                AllSetView(
                    viewModel: viewModel,
                    onTriggerZoomAndFinish: onTriggerZoom
                )
            }
        }
        .opacity(viewModel.step == .globe ? 0 : 1)
    }

    private var welcomeCard: some View {
        OnboardingCardShell(
            content: {
                VStack(spacing: 12) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                    Text("Know Your Zone")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Real-time health + environment signals,\nright on your wrist.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
            },
            buttonTitle: "Let's go",
            buttonAction: { viewModel.advance() },
            progressSteps: 6,
            currentStepIndex: 0
        )
    }

    private var whyItMattersCard: some View {
        OnboardingCardShell(
            content: {
                ScrollView {
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color(hex: "#34C759"))
                        Text("Built for your community")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                        Text("ENDO fuses air quality, heat, heart rate, and neighborhood resources to score your environment — anonymously.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                    }
                    .frame(maxWidth: .infinity)
                }
                .focusable()
            },
            buttonTitle: "Got it",
            buttonAction: { viewModel.advance() },
            progressSteps: 6,
            currentStepIndex: 1
        )
    }
}
