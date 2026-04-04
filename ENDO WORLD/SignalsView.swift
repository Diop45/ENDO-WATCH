import SwiftUI

struct SignalsView: View {
    @Binding var enabled: Set<String>
    var onContinue: () -> Void

    private let rows: [(id: String, title: String, subtitle: String)] = [
        ("env", "Environment", "Air, noise, heat, and neighborhood context"),
        ("bio", "Biometrics", "Heart rate, HRV, and recovery signals"),
        ("move", "Movement", "Walking, activity, and route context")
    ]

    var body: some View {
        ZStack {
            Color.obBg.ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Which signals should ENDO emphasize?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.obNavy)
                    Text("You can change this anytime in Settings.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.obSlate)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(rows, id: \.id) { row in
                            SignalToggleRow(
                                title: row.title,
                                subtitle: row.subtitle,
                                isOn: enabled.contains(row.id),
                                toggle: {
                                    if enabled.contains(row.id) {
                                        enabled.remove(row.id)
                                    } else {
                                        enabled.insert(row.id)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }

                Button("Continue", action: onContinue)
                    .primaryCTA(bg: Color.obNavy, fg: .white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .contentShape(Rectangle())
            }
        }
    }
}

private struct SignalToggleRow: View {
    let title: String
    let subtitle: String
    let isOn: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.obNavy)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.obSlate)
                }
                Spacer()
                Text(isOn ? "On" : "Off")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isOn ? Color.obCyan : Color.obMuted)
            }
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.black.opacity(0.06), lineWidth: 0.5)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
