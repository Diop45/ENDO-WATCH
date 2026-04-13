import SwiftUI

struct EndoStubTabView: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}
