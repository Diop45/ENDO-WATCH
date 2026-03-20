import SwiftUI

struct AllSetView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onTriggerZoomAndFinish: () -> Void

    @State private var checkProgress = 0.0

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 16) {
                // Animated checkmark
                Circle()
                    .trim(from: 0, to: checkProgress)
                    .stroke(
                        Color(hex: "#34C759"),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))

                Text("You're all set")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)

                Text("Scanning your zone…")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .frame(height: geo.size.height * 0.4)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: checkProgress)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                checkProgress = 1.0
            }
            Task {
                try? await Task.sleep(nanoseconds: 1_400_000_000)
                onTriggerZoomAndFinish()
            }
        }
    }
}
