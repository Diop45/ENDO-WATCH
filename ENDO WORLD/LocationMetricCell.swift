import SwiftUI

struct LocationMetricCell: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading,
               spacing: 5) {
            Text(label)
                .font(.system(
                    size: 8, weight: .medium))
                .foregroundStyle(
                    .white.opacity(0.28))
                .textCase(.uppercase)
                .kerning(0.6)
                .lineLimit(1)
            Text(value)
                .font(.system(
                    size: 18, weight: .bold))
                .foregroundStyle(color)
                .minimumScaleFactor(0.65)
                .lineLimit(1)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.bgElevated)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 8,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 8,
                style: .continuous)
                .strokeBorder(
                    color.opacity(0.12),
                    lineWidth: 0.5))
    }
}
