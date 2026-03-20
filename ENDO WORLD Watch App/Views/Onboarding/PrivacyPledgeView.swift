import SwiftUI

struct PrivacyPledgeView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingCardShell(
            content: {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                        Text("Your data, anonymous")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)

                        bulletRow(icon: "shield.fill", text: "Coordinates rounded to 110 m")
                        bulletRow(icon: "clock.fill", text: "Timestamps rounded to the hour")
                        bulletRow(icon: "person.fill.questionmark", text: "ID is a one-way SHA-256 hash")

                        HStack {
                            Text("Share anonymous pins")
                                .font(.system(size: 13))
                                .foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: $viewModel.shareConsent)
                                .labelsHidden()
                                .tint(Color(hex: "#34C759"))
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .focusable()
                .onChange(of: viewModel.shareConsent) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "endo.shareConsent")
                }
            },
            buttonTitle: "I understand",
            buttonAction: { viewModel.advance() },
            progressSteps: 6,
            currentStepIndex: 5
        )
    }

    private func bulletRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
    }
}
