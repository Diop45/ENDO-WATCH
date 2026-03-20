import SwiftUI

// MARK: - WatchOnboardingShell
// No card wrapper. Content directly on powder blue background.
// Dot progress row fixed top. Content constrained to 166pt.

struct WatchOnboardingShell<Content: View>: View {
    let stepIndex: Int
    let onBack: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#E8F4F8").ignoresSafeArea()

            VStack(spacing: 0) {
                dotProgress
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, 10)
            }
        }
    }

    private var dotProgress: some View {
        ZStack {
            HStack(spacing: 3) {
                ForEach(0..<11, id: \.self) { i in
                    Circle()
                        .fill(i == stepIndex ? Color(hex: "#00B4D8") : Color(hex: "#C5D8E0"))
                        .frame(width: 4, height: 4)
                }
            }
            if stepIndex > 0 {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(hex: "#4A6274"))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }
        }
        .frame(height: 14)
        .padding(.horizontal, 10)
        .padding(.top, 5)
        .padding(.bottom, 3)
    }
}

// MARK: - Shared helpers

func cyanButton(_ label: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(Color(hex: "#00B4D8"))
            .clipShape(RoundedRectangle(cornerRadius: 9))
    }
    .buttonStyle(.plain)
}

func tapHint(onTap: @escaping () -> Void) -> some View {
    Button(action: onTap) {
        HStack(spacing: 4) {
            Spacer()
            Text("Swipe to learn")
                .font(.system(size: 9))
                .foregroundStyle(Color(hex: "#4A6274"))
            Image(systemName: "arrow.right")
                .font(.system(size: 8))
                .foregroundStyle(Color(hex: "#00B4D8"))
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
    .buttonStyle(.plain)
}

func factCell(icon: String, color: Color, text: String) -> some View {
    HStack(spacing: 3) {
        Image(systemName: icon)
            .font(.system(size: 8))
            .foregroundStyle(color)
        Text(text)
            .font(.system(size: 9))
            .foregroundStyle(Color(hex: "#4A6274"))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 5)
    .padding(.vertical, 4)
    .background(Color(hex: "#00B4D8").opacity(0.07))
    .clipShape(RoundedRectangle(cornerRadius: 5))
}
