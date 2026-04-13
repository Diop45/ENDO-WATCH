import SwiftUI

struct UseCasePanel: View {
    @Bindable var vm: MapViewModel
    @State private var isExpanded = false

    private static let useCaseTitles: [String] = [
        "Morning route · asthma",
        "Chronic condition check",
        "Care desert alert",
        "Food + disease compound",
        "Route to clean zone",
        "Heat alert · elderly",
        "Community challenge",
        "SVI vulnerability",
        "Asthma risk route",
        "Green space recovery",
    ]

    private static let useCaseColors: [Color] = [
        .endoRed,
        .endoAmber,
        .endoRed,
        .endoPurple,
        .endoGreen,
        .endoAmber,
        .endoCyan,
        .endoPurple,
        .endoRed,
        .endoGreen,
    ]

    static func runUseCase(
        index: Int,
        vm: MapViewModel
    ) {
        switch index {
        case 0: vm.activateMorningRoute()
        case 1: vm.activateChronicCheck()
        case 2: vm.activateCareDesertAlert()
        case 3: vm.activateFoodDiseaseCompound()
        case 4: vm.activateCleanZoneRoute()
        case 5: vm.activateHeatAlert()
        case 6: vm.activateCommunityChallenge()
        case 7: vm.activateSVIView()
        case 8: vm.activateAsthmaRoute()
        case 9: vm.activateGreenSpaceRecovery()
        default: break
        }
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Button {
                withAnimation(
                    .spring(duration: 0.3,
                            bounce: 0.1)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName:
                        isExpanded
                        ? "xmark" : "list.bullet")
                        .font(.system(
                            size: 12, weight: .semibold))
                    if !isExpanded {
                        Text("Use cases")
                            .font(.system(
                                size: 11,
                                weight: .semibold))
                    }
                }
                .foregroundStyle(Color.endoCyan)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Color.bgSheet.opacity(0.95))
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(
                        Color.endoCyan.opacity(0.30),
                        lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .contentShape(Capsule())

            if isExpanded {
                VStack(spacing: 1) {
                    ForEach(
                        Self.useCaseTitles.indices,
                        id: \.self
                    ) { index in
                        Button {
                            Self.runUseCase(index: index, vm: vm)
                            withAnimation {
                                isExpanded = false
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Self.useCaseColors[index])
                                    .frame(width: 6,
                                           height: 6)
                                Text(Self.useCaseTitles[index])
                                    .font(.system(size: 11))
                                    .foregroundStyle(
                                        .white.opacity(0.80))
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Color.bgSheet.opacity(0.97))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous))
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous)
                        .strokeBorder(
                            .white.opacity(0.08),
                            lineWidth: 0.5))
                .transition(
                    .move(edge: .trailing)
                        .combined(with: .opacity))
            }
        }
    }
}

#Preview {
    @Previewable @State var vm = MapViewModel()
    UseCasePanel(vm: vm)
        .padding()
        .background(Color.bgPrimary)
}
