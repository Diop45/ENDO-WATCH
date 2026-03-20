import SwiftUI

struct DashboardView: View {

    @State private var viewModel = ENDOWatchViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                timeHeader
                ZoneStatusCard(viewModel: viewModel)
                HeartRateCard(viewModel: viewModel)
                HRVCard(viewModel: viewModel)
                AQICard(viewModel: viewModel)
                VO2Card(viewModel: viewModel)
                PM25Card(viewModel: viewModel)
                NoiseCard(viewModel: viewModel)
            }
            .padding(.horizontal, 8)
        }
        .background(Color.background)
        .task { await viewModel.load() }
        .onAppear { viewModel.startPassiveUpdates() }
    }

    private var timeHeader: some View {
        Text(Date(), style: .time)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.labelGray)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 4)
    }
}
