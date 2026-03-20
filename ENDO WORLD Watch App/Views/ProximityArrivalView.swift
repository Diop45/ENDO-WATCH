import SwiftUI

// MARK: - ProximityArrivalView
// Shown when navigating seek route AND within 500ft of supportive zone.

struct ProximityArrivalView: View {
    let zone: ZoneClassification
    let proximityProgress: Double
    let hrBefore: Double
    let hrNow: Double
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var zoneColor: Color { zone.color }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    topSection
                    rangeBar
                    bottomSection
                }
                ProximityGauge(progress: proximityProgress, color: zoneColor)
            }
            .background(
                VStack(spacing: 0) {
                    Color(hex: "#F2F2F0")
                        .frame(height: geo.size.height * 0.52)
                    Color(hex: "#0A0A0F")
                }
            )
        }
        .ignoresSafeArea()
    }

    private var topSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(zoneColor)
                Text(Date(), style: .time)
                    .font(.system(size: 10))
                    .foregroundStyle(.black.opacity(0.5))
            }
            HStack(alignment: .bottom) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundStyle(.black.opacity(0.35))
                VStack(alignment: .leading, spacing: 2) {
                    Text(statusText)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.black)
                    Text("to zone")
                        .font(.system(size: 10))
                        .foregroundStyle(.black.opacity(0.5))
                }
                .padding(.leading, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusText: String {
        if proximityProgress >= 1.0 { return "You're in \(zone.rawValue)" }
        if proximityProgress > 0.9 { return "Almost there" }
        return "Approaching"
    }

    private var rangeBar: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(i < Int(proximityProgress * 5)
                          ? LinearGradient(
                            colors: [Color(hex: "#A8D8FF"), zoneColor, Color(hex: "#D4A8FF")],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                          : LinearGradient(
                            colors: [Color(red: 0.78, green: 0.78, blue: 0.78, opacity: 0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                          ))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private var bottomSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Before")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("\(Int(hrBefore))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                Image(systemName: "arrow.right")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Now")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("\(Int(hrNow))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(zoneColor)
                }
                .padding(.leading, 8)
            }

            Button("End Navigation") {
                onDismiss()
                dismiss()
            }
            .font(.system(size: 11))
            .foregroundStyle(.white.opacity(0.5))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#0A0A0F"))
    }
}
