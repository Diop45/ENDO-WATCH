import SwiftUI
import MapKit

// MARK: - PinDetailSheet
// Full-width sheet when a zone pin is tapped. Signal rows + Avoid / Go Toward.

struct PinDetailSheet: View {
    let pin: ENDOZonePin
    @Bindable var viewModel: WatchZoneViewModel
    @Bindable var navService: WatchNavigationService
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var aqi: Int { viewModel.aqi }
    private var pm25: Double { viewModel.locationService.latestEnvironmental?.pm25 ?? 0 }
    private var noise: Double { viewModel.noiseLevel }
    private var hr: Double { viewModel.heartRate }
    private var hrv: Double { viewModel.hrv }

    var body: some View {
        VStack(spacing: 0) {
            header
            signalRows
            Divider()
                .background(.white.opacity(0.2))
                .padding(.vertical, 8)
            actionButtons
        }
        .padding()
        .background(Color.endoBackground)
        .onDisappear { onDismiss() }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(pin.zone.color.opacity(0.3))
                        .frame(width: 28, height: 28)
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(pin.zone.rawValue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(pin.zone.color)
                Text("\(pin.compositeScore)/100 · \(pin.dominantSignal)")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.leading, 8)
            Spacer()
        }
        .padding(.bottom, 12)
    }

    private var signalRows: some View {
        VStack(spacing: 6) {
            signalRow(label: "AQI", value: "\(aqi)", color: signalColor(for: "AQI", value: Double(aqi)))
            signalRow(label: "PM2.5", value: String(format: "%.1f", pm25), color: signalColor(for: "PM2.5", value: pm25))
            signalRow(label: "Noise", value: "\(Int(noise))dB", color: signalColor(for: "Noise", value: noise))
            signalRow(label: "HR", value: "\(Int(hr))", color: Color.endoCyan)
            signalRow(label: "HRV", value: "\(Int(hrv))", color: signalColor(for: "HRV", value: hrv))
        }
    }

    private func signalRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private func signalColor(for label: String, value: Double) -> Color {
        switch label {
        case "AQI": return value > 100 ? Color.endoRed : (value > 50 ? Color.endoAmber : Color.endoCyan)
        case "PM2.5": return value > 35 ? Color.endoRed : (value > 12 ? Color.endoAmber : Color.endoCyan)
        case "Noise": return value > 70 ? Color.endoRed : (value > 55 ? Color.endoAmber : Color.endoCyan)
        case "HRV": return value < 30 ? Color.endoRed : (value < 50 ? Color.endoAmber : Color.endoCyan)
        default: return Color.endoCyan
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 8) {
            Button(action: avoidTapped) {
                HStack {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("Avoid this area")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(Color.endoRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.endoRed.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.endoRed.opacity(0.5), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            Button(action: goTowardTapped) {
                HStack {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.system(size: 12))
                    Text("Go toward")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(Color.endoCyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.endoCyan.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.endoCyan.opacity(0.5), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    private func avoidTapped() {
        navService.start(intent: .avoid, destination: pin)
        dismiss()
    }

    private func goTowardTapped() {
        navService.start(intent: .seek, destination: pin)
        dismiss()
    }
}
