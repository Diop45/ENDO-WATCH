import SwiftUI

// MARK: - ZoneDetailView
// Full-screen radial composite score with 2×2 category grid per spec.

struct ZoneDetailView: View {
    @Bindable var viewModel: WatchZoneViewModel
    @Environment(\.dismiss) private var dismiss

    private var score: Int { viewModel.compositeScore }
    private var zone: ZoneClassification { viewModel.currentZone }
    private var zoneColor: Color { zone.color }

    var body: some View {
        VStack(spacing: 12) {
            compassRing
            Text("\(activeSignalCount) signals active")
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.5))
            categoryGrid
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.endoBackground)
        .onTapGesture { dismiss() }
    }

    private var compassRing: some View {
        ZStack {
            Circle()
                .strokeBorder(.white.opacity(0.1), lineWidth: 3)
                .frame(width: 80, height: 80)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100.0)
                .stroke(zoneColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(zoneColor)
                Text(zone.rawValue)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    private var activeSignalCount: Int {
        var count = 0
        if viewModel.heartRate > 0 { count += 1 }
        if viewModel.hrv > 0 { count += 1 }
        if viewModel.aqi > 0 { count += 1 }
        if viewModel.noiseLevel > 0 { count += 1 }
        return max(count, 4)
    }

    private var categoryGrid: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                categoryCell(label: "BIO", value: bioValue, color: zoneColor)
                categoryCell(label: "ENV", value: "\(viewModel.aqi) AQI", color: zoneColor)
            }
            HStack(spacing: 8) {
                categoryCell(label: "MOV", value: "Active", color: .white)
                categoryCell(label: "URB", value: "\(Int(viewModel.noiseLevel))dB", color: .white)
            }
        }
    }

    private func categoryCell(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(color.opacity(0.9))
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(hex: "#1A1A2E"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var bioValue: String {
        if viewModel.heartRate > 0 { return "\(Int(viewModel.heartRate)) bpm" }
        return "Low"
    }
}
