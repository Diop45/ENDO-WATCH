import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()

            Color(hex: "#005AB4")
                .opacity(0.18)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .offset(y: -120)

            VStack(spacing: 0) {
                Spacer()

                ENDOGlobe(size: 80)
                    .padding(.bottom, 20)

                Text("endo")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.30))
                    .kerning(0.5)
                    .padding(.bottom, 48)

                Spacer()

                VStack(spacing: 0) {
                    Text("right now,")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.bottom, 6)

                    Text("your neighborhood\nis shaping your health.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.bottom, 10)

                    Text("Most people never know what their block is doing to their body.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 32)

                VStack(spacing: 12) {
                    Button("Sign up", action: onContinue)
                        .primaryCTA(bg: .white, fg: Color(hex: "#07070D"))
                        .contentShape(Capsule())

                    Text("or continue with")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.white.opacity(0.28))

                    HStack(spacing: 10) {
                        WelcomeSSOButton(label: "G", action: onContinue)
                        WelcomeSSOButton(systemImage: "apple.logo", action: onContinue)
                    }

                    Text("By continuing you agree to our Terms & Privacy Policy")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.white.opacity(0.22))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 52)
            }
        }
    }
}

private struct WelcomeSSOButton: View {
    var label: String = ""
    var systemImage: String = ""
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Capsule()
                    .fill(.white.opacity(0.08))
                    .overlay(
                        Capsule()
                            .strokeBorder(.white.opacity(0.16), lineWidth: 0.5)
                    )
                Group {
                    if !systemImage.isEmpty {
                        Image(systemName: systemImage)
                            .font(.system(size: 14, weight: .medium))
                    } else {
                        Text(label)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 46)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
