import SwiftUI

struct CollectiveScanBadgeView: View {
    let defenderCount: Int
    let nodeColor: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 7))
                .foregroundStyle(nodeColor)
            Text("\(defenderCount)")
                .font(.system(
                    size: 8, weight: .bold))
                .foregroundStyle(nodeColor)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(
            Color.bgSheet.opacity(0.90))
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(
                nodeColor.opacity(0.30),
                lineWidth: 0.5))
    }
}

#Preview {
    HStack(spacing: 16) {
        CollectiveScanBadgeView(
            defenderCount: 1,
            nodeColor: .endoCyan)
        CollectiveScanBadgeView(
            defenderCount: 12,
            nodeColor: .endoAmber)
    }
    .padding()
    .background(Color.bgPrimary)
}
