import SwiftUI

/// Top map chrome: profile (left), metric pills, lens menu — matches wireframe header row.
struct WireframeMapTopChrome: View {
    @Bindable var vm: MapViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            ProfileBiometricClusterView(
                friendsVisible: $vm.friendsVisible)

            ScrollView(.horizontal, showsIndicators: false) {
                WireframeMetricPillsRow()
            }

            Spacer(minLength: 4)

            if vm.healthLayerOn {
                lensMenu
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 12)
        .padding(.top, 52)
    }

    private var lensMenu: some View {
        Menu {
            ForEach(NodeLens.allCases, id: \.self) { lens in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.activeLens = lens
                    }
                } label: {
                    HStack {
                        Text(lens.rawValue)
                        if vm.activeLens == lens {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Text("Lens")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.72))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.bgSurface)
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(
                        Color.white.opacity(0.12),
                        lineWidth: 0.5))
        }
        .menuStyle(.automatic)
    }
}

#Preview("Health on") {
    @Previewable @State var vm = MapViewModel()
    WireframeMapTopChrome(vm: vm)
        .environment(AppState())
        .background(Color.bgPrimary)
        .onAppear {
            vm.healthLayerOn = true
            vm.friends = MockService.friends()
        }
}

#Preview("Health off") {
    @Previewable @State var vm = MapViewModel()
    WireframeMapTopChrome(vm: vm)
        .environment(AppState())
        .background(Color.bgPrimary)
}
