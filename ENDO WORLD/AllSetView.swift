import SwiftUI

struct AllSetView: View {
    var onEnter: () -> Void

    var body: some View {
        ZStack {
            Color.obBg.ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                Text("You're set")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.obNavy)
                Text("Your block score updates as you move. Open Today to see the full picture.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.obSlate)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 32)
                Spacer()
                Button("Enter ENDO", action: onEnter)
                    .primaryCTA(bg: Color.obCyan, fg: .white)
                    .padding(.horizontal, 24)
                    .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
