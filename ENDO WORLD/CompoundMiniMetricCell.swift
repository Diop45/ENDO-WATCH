import SwiftUI

struct CompoundMiniMetricCell: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(
                    size: 8, weight: .medium))
                .foregroundStyle(
                    .white.opacity(0.28))
                .textCase(.uppercase)
                .kerning(0.6)
            Text(value)
                .font(.system(
                    size: 13, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity,
               alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.bgElevated)
        .clipShape(RoundedRectangle(
            cornerRadius: 6))
    }
}

#Preview {
    HStack(spacing: 8) {
        CompoundMiniMetricCell(
            label: "AQI",
            value: "148",
            color: .endoAmber)
        CompoundMiniMetricCell(
            label: "PM2.5",
            value: "12 µg/m³",
            color: .endoCyan)
    }
    .padding()
    .background(Color.bgPrimary)
}
