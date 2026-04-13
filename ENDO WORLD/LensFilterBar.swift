import SwiftUI

struct LensFilterBar: View {
    @Binding var active: NodeLens

    var body: some View {
        ScrollView(.horizontal,
                   showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(
                    NodeLens.allCases,
                    id: \.self
                ) { lens in
                    Button {
                        withAnimation(
                            .easeInOut(duration: 0.2)) {
                            active = lens
                        }
                    } label: {
                        HStack(spacing: 5) {
                            if lens != .all {
                                Circle()
                                    .fill(lens.color)
                                    .frame(width: 5, height: 5)
                            }
                            Text(lens.rawValue)
                                .font(.system(
                                    size: 13,
                                    weight: .semibold))
                                .foregroundStyle(
                                    active == lens
                                        ? .white
                                        : .white.opacity(0.42))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            active == lens
                                ? lens.color.opacity(0.20)
                                : Color.bgSurface)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(
                                active == lens
                                    ? lens.color.opacity(0.50)
                                    : .white.opacity(0.10),
                                lineWidth: 0.5))
                    }
                    .buttonStyle(.plain)
                    .contentShape(Capsule())
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

#Preview {
    @Previewable @State var active: NodeLens = .all
    LensFilterBar(active: $active)
        .padding()
        .background(Color.bgPrimary)
}
