import SwiftUI

struct MapCtrlBtn: View {
    let icon: String
    var active: Bool = false
    var accent: Color = .endoCyan
    var badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous)
                        .fill(
                            active
                                ? accent.opacity(0.15)
                                : Color.bgSheet.opacity(0.90))
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous)
                        .strokeBorder(
                            active
                                ? accent.opacity(0.40)
                                : Color.white.opacity(0.08),
                            lineWidth: 0.5)
                    Image(systemName: icon)
                        .font(.system(
                            size: 15,
                            weight: .medium))
                        .foregroundStyle(
                            active
                                ? accent
                                : Color.white
                                    .opacity(0.55))
                }
                .frame(width: 40, height: 40)

                if let badge {
                    Text(badge)
                        .font(.system(
                            size: 8, weight: .bold))
                        .foregroundStyle(
                            Color(hex: "#042C53"))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.endoCyan)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview("Default") {
    MapCtrlBtn(icon: "location.fill") {}
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Active") {
    MapCtrlBtn(
        icon: "waveform.path.ecg.rectangle",
        active: true,
        accent: .endoCyan
    ) {}
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Badge") {
    MapCtrlBtn(
        icon: "person.2.fill",
        active: true,
        badge: "3"
    ) {}
        .padding()
        .background(Color.bgPrimary)
}
