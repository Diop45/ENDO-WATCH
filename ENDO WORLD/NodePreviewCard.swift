import SwiftUI

struct NodePreviewCard: View {
    let node: HealthNode
    let userHR: Int
    let userHRV: Int
    var onExpand: () -> Void
    var onDismiss: () -> Void
    var dismissDragThreshold: CGFloat = 60
    var onExitChallenge: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            if let exit = onExitChallenge {
                Button(action: exit) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(
                                size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.55))
                        Text("Exit challenge")
                            .font(.system(
                                size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.bgSurface)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous))
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous)
                            .strokeBorder(
                                .white.opacity(0.12),
                                lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 4)
            }

            HStack(alignment: .top,
                   spacing: 10) {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: 9,
                        style: .continuous)
                        .fill(
                            node.primaryLens.color
                                .opacity(0.14))
                        .frame(width: 40, height: 40)
                    RoundedRectangle(
                        cornerRadius: 9,
                        style: .continuous)
                        .strokeBorder(
                            node.primaryLens.color
                                .opacity(0.30),
                            lineWidth: 0.8)
                        .frame(width: 40, height: 40)
                    Image(
                        systemName: node.type.icon)
                        .font(.system(
                            size: 16,
                            weight: .semibold))
                        .foregroundStyle(
                            node.primaryLens.color)
                }

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text(node.title)
                        .font(.system(
                            size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(node.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(
                            .white.opacity(0.38))
                        .lineLimit(1)
                }

                Spacer()

                if let score = node.score {
                    Text("\(score)")
                        .font(.system(
                            size: 13, weight: .bold))
                        .foregroundStyle(
                            node.primaryLens.color)
                        .frame(width: 32, height: 32)
                        .background(
                            node.primaryLens.color
                                .opacity(0.12))
                        .clipShape(Circle())
                        .overlay(
                            Circle().strokeBorder(
                                node.primaryLens.color
                                    .opacity(0.25),
                                lineWidth: 0.5))
                }

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(
                            size: 10, weight: .medium))
                        .foregroundStyle(
                            .white.opacity(0.28))
                        .frame(
                            width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 10)

            HStack(spacing: 4) {
                ForEach(
                    node.envMetrics.prefix(2)
                ) { m in
                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {
                        Text(m.label)
                            .font(.system(
                                size: 7, weight: .medium))
                            .foregroundStyle(
                                .white.opacity(0.25))
                            .textCase(.uppercase)
                            .kerning(0.5)
                        Text(m.value)
                            .font(.system(
                                size: 16, weight: .bold))
                            .foregroundStyle(m.color)
                            .lineLimit(1)
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.bgElevated)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 7))
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 6)

            Text(node.interpretation)
                .font(.system(size: 11))
                .foregroundStyle(
                    .white.opacity(0.38))
                .lineLimit(2)
                .lineSpacing(3)
                .padding(.horizontal, 14)
                .padding(.bottom, 8)

            Rectangle()
                .fill(.white.opacity(0.06))
                .frame(height: 0.5)
                .padding(.horizontal, 14)

            HStack(spacing: 6) {
                Text("MY READINGS")
                    .font(.system(
                        size: 7, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.25))
                    .kerning(0.8)
                    .textCase(.uppercase)
                Spacer()
                bioPill(
                    label: "HR",
                    value: "\(userHR) bpm",
                    color: hrColor(Double(userHR)))
                bioPill(
                    label: "HRV",
                    value: "\(userHRV) ms",
                    color: hrvColor(Double(userHRV)))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Button(action: onExpand) {
                HStack {
                    Text("Full location detail")
                        .font(.system(
                            size: 11,
                            weight: .semibold))
                        .foregroundStyle(
                            node.primaryLens.color)
                    Spacer()
                    Image(
                        systemName:
                            "arrow.up.right.circle")
                        .font(.system(
                            size: 12,
                            weight: .medium))
                        .foregroundStyle(
                            node.primaryLens.color
                                .opacity(0.55))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    node.primaryLens.color
                        .opacity(0.07))
            }
            .buttonStyle(.plain)
        }
        .background(Color.bgSheet.opacity(0.97))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous)
                .strokeBorder(
                    node.primaryLens.color
                        .opacity(0.18),
                    lineWidth: 0.5))
        .contentShape(Rectangle())
        .onTapGesture { onExpand() }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.height < -30 {
                        onExpand()
                    }
                    if value.translation.height > dismissDragThreshold {
                        onDismiss()
                    }
                })
    }

    private func bioPill(
        label: String,
        value: String,
        color: Color
    ) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(
                    size: 7, weight: .medium))
                .foregroundStyle(
                    .white.opacity(0.28))
                .textCase(.uppercase)
            Text(value)
                .font(.system(
                    size: 9, weight: .bold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Color.bgElevated)
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(
                color.opacity(0.18),
                lineWidth: 0.5))
    }
}

#Preview {
    NodePreviewCard(
        node: MockService.nodes()[0],
        userHR: 72,
        userHRV: 48,
        onExpand: {},
        onDismiss: {},
        onExitChallenge: nil)
        .padding()
        .background(Color.bgPrimary)
}
