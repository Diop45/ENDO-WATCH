import SwiftUI

struct ScoreRingView: View {
    let score: Int
    let label: String
    let color: Color
    var showCrown: Bool { score >= 85 }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .strokeBorder(.white.opacity(0.08), lineWidth: 7)
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100.0)
                    .stroke(color, style: StrokeStyle(lineWidth: 6.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 1) {
                    Text("\(score)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    if showCrown {
                        Text("👑")
                            .font(.system(size: 10))
                    }
                }
            }
            .frame(width: 72, height: 72)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(color)
        }
    }
}
