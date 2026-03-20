import SwiftUI

struct OnboardingCardShell<Content: View>: View {
    @ViewBuilder let content: () -> Content
    let buttonTitle: String
    let buttonAction: () -> Void
    let progressSteps: Int
    let currentStepIndex: Int
    var buttonDisabled: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Progress dots
            HStack(spacing: 5) {
                ForEach(0..<progressSteps, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(i == currentStepIndex ? 1.0 : 0.3))
                        .frame(width: 5, height: 5)
                }
            }
            .padding(.bottom, 10)

            content()

            Spacer(minLength: 12)

            // Primary button
            Button(action: buttonAction) {
                Text(buttonTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
            .disabled(buttonDisabled)
            .background(Color(hex: "#34C759").opacity(buttonDisabled ? 0.7 : 1), in: Capsule())
            .padding(.horizontal, 24)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxHeight: .infinity, alignment: .bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: currentStepIndex)
    }
}
