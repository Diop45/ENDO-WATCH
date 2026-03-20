import SwiftUI
import Combine

// MARK: - WatchHomeView
// Root view of the watchOS app. Full-screen, edge-to-edge, no navigation chrome.
// Divided into three vertical zones:
//   Top    28% — time + date
//   Middle 44% — scan button
//   Bottom 28% — AQI / zone / updated tiles

struct WatchHomeView: View {

    @State private var viewModel    = WatchHomeViewModel()
    @State private var clockDate    = Date()
    @State private var isScanning   = false   // drives repeating opacity animation

    // Detects always-on display (WatchOS AOD / Luminance Reduced state).
    @Environment(\.isLuminanceReduced) private var isAOD

    // Clock ticks every 60 seconds — drives both time display and elapsed-time tile.
    private let clockTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    topZone
                        .frame(height: geo.size.height * 0.28)

                    middleZone
                        .frame(height: geo.size.height * 0.44)

                    bottomZone
                        .frame(height: geo.size.height * 0.28)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .onReceive(clockTimer) { date in
            clockDate = date
        }
        .onChange(of: viewModel.scanState) { _, state in
            isScanning = (state == .scanning)
        }
    }

    // MARK: - Top zone — time + date

    private var topZone: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Line 1: current time, SF Pro Display thin 28pt
            Text(timeString)
                .font(.system(size: 28, weight: .thin))
                .foregroundStyle(.white)
                .opacity(isAOD ? 0.2 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isAOD)

            // Line 2: date "FRI · MAR 20", SF Pro Display thin 11pt, tracked wide
            Text(dateString)
                .font(.system(size: 11, weight: .thin))
                .tracking(1.4)
                .foregroundStyle(Color(hex: "#8E8E93"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.horizontal, 14)
        .padding(.bottom, 4)
    }

    // MARK: - Middle zone — scan button

    private var middleZone: some View {
        Button {
            guard !isAOD else { return }
            viewModel.beginScan()
        } label: {
            ZStack {
                // Button shape: black fill + cyan stroke
                Circle()
                    .fill(Color.black)
                Circle()
                    .strokeBorder(
                        Color(hex: "#00E5FF"),
                        lineWidth: isAOD ? 0.5 : 1.5
                    )
                    .animation(.easeInOut(duration: 0.3), value: isAOD)

                // Button content
                VStack(spacing: 5) {
                    Image(systemName: symbolName)
                        .font(.system(size: 22, weight: .thin))
                        .foregroundStyle(symbolForeground)
                        // Pulse animation while scanning
                        .opacity(isScanning ? 0.3 : 1.0)
                        .animation(
                            isScanning
                                ? .linear(duration: 0.9).repeatForever(autoreverses: true)
                                : .easeOut(duration: 0.2),
                            value: isScanning
                        )

                    Text("SCAN")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 88, height: 88)
        }
        .buttonStyle(.plain)
        .disabled(isAOD)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bottom zone — complication tiles

    private var bottomZone: some View {
        HStack(spacing: 6) {
            tile(
                label: "AQI",
                value: isAOD ? "——" : viewModel.aqiDisplayValue,
                valueColor: isAOD ? Color(hex: "#8E8E93") : viewModel.aqiColor
            )
            tile(
                label: "ZONE",
                value: isAOD ? "——" : viewModel.zoneDisplayValue,
                valueColor: isAOD ? Color(hex: "#8E8E93") : viewModel.zoneColor
            )
            tile(
                label: "UPDATED",
                value: isAOD ? "——" : viewModel.elapsedDisplayValue,
                valueColor: isAOD ? Color(hex: "#8E8E93") : .white
            )
        }
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    // MARK: - Tile component

    @ViewBuilder
    private func tile(label: String, value: String, valueColor: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(Color(hex: "#8E8E93"))
                .textCase(.uppercase)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.25), value: value)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#141420"))
        )
    }

    // MARK: - Derived symbol properties

    private var symbolName: String {
        switch viewModel.scanState {
        case .idle, .scanning: return "dot.radiowaves.up.forward"
        case .success:         return "checkmark.circle.fill"
        case .failure:         return "exclamationmark.circle.fill"
        }
    }

    private var symbolForeground: Color {
        switch viewModel.scanState {
        case .idle, .scanning, .success: return Color(hex: "#00E5FF")
        case .failure:                   return Color(hex: "#FF9F0A")
        }
    }

    // MARK: - Date / time helpers

    private var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm"
        return f.string(from: clockDate)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEE · MMM d"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: clockDate).uppercased()
    }
}

// MARK: - Preview

#Preview {
    WatchHomeView()
}
