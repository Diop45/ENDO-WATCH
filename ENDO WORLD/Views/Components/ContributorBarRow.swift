import SwiftUI

struct ContributorBarRow: View {
    let label: String
    let value: String
    let progress: Double
    let color: Color
    let status: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                Text(value)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(color)
                Text(status)
                    .font(.system(size: 10))
                    .foregroundStyle(color.opacity(0.8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.2))
                    .clipShape(Capsule())
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.1))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 6)
    }
}
