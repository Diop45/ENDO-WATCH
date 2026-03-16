import SwiftUI

struct ZoneStatusCard: View {

    let viewModel: ENDOWatchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Text("Zone Status")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Spacer()
                Text(viewModel.locationLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }

            zoneBarChart

            Text(viewModel.zoneClassification.rawValue)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(viewModel.zoneClassification.color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(viewModel.compositeScore)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.nearBlack)
                Text("/ 100")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(viewModel.zoneClassification.color)
                .frame(width: 3)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0
                    )
                )
        }
    }

    private var zoneBarChart: some View {
        HStack(alignment: .bottom, spacing: 1) {
            ForEach(0..<24, id: \.self) { index in
                let isLast = index == 23
                let height = barHeight(at: index)
                RoundedRectangle(cornerRadius: 2)
                    .fill(viewModel.zoneClassification.color.opacity(isLast ? 1.0 : 0.2))
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
            }
        }
        .frame(height: 28)
    }

    private func barHeight(at index: Int) -> CGFloat {
        guard index < viewModel.zoneScoreHistory.count else {
            return CGFloat(viewModel.compositeScore) / 100.0 * 28
        }
        return CGFloat(viewModel.zoneScoreHistory[index]) / 100.0 * 28
    }
}
