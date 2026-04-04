import SwiftUI

struct HealthView: View {
    private let areas = defaultHealthAreas

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("My Health")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)

                Text("Environmental areas load first, then biometric load.")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 4)

                ForEach(areas) { area in
                    HealthAreaRow(area: area)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .background(Color.bgPrimary.ignoresSafeArea())
    }
}

private struct HealthAreaRow: View {
    let area: HealthArea

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(area.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text(area.status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(area.color)
            }
            Text(area.isEnvironmental ? "Public health · environment" : "Biometric response")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.32))
                .textCase(.uppercase)
                .kerning(0.8)
            ENDOProgressBar(value: area.progress, color: area.color)
        }
        .padding(12)
        .endoCard(bg: .bgCard, border: .white.opacity(0.08))
        .contentShape(Rectangle())
    }
}
