import SwiftUI

// MARK: - ProximityGauge
// Vertical progress bar for proximity warning/arrival views.

struct ProximityGauge: View {
    let progress: Double
    let color: Color

    @State private var isPulsing = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(.white.opacity(0.08))
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(color)
                    .frame(height: geo.size.height * progress)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                    .scaleEffect(x: isPulsing ? 1.3 : 1.0)
                    .animation(
                        progress >= 0.8
                            ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                            : .default,
                        value: isPulsing
                    )
            }
        }
        .frame(width: 5)
        .onChange(of: progress) { _, new in
            isPulsing = new >= 0.8
        }
    }
}
