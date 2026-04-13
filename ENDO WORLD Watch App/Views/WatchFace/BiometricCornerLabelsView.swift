import SwiftUI

/// Watch face corner labels for vitals (layout placeholder).
struct BiometricCornerLabelsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("HR")
                .font(.system(size: 8, weight: .medium))
            Text("72")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    BiometricCornerLabelsView()
}
