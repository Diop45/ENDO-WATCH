import SwiftUI

private struct CondCat: Identifiable {
    let id: String
    let title: String
    let color: Color
    let conditions: [String]
}

private let conditionCategories: [CondCat] = [
    CondCat(
        id: "resp",
        title: "Respiratory",
        color: Color(hex: "#00B4D8"),
        conditions: ["Asthma", "COPD", "Allergies", "Bronchitis"]
    ),
    CondCat(
        id: "cardio",
        title: "Cardiovascular",
        color: Color(hex: "#FF6B6B"),
        conditions: ["Hypertension", "Heart disease", "Arrhythmia"]
    ),
    CondCat(
        id: "meta",
        title: "Metabolic",
        color: Color(hex: "#FFB800"),
        conditions: ["Type 2 Diabetes", "Obesity", "Thyroid"]
    ),
    CondCat(
        id: "neuro",
        title: "Neurological",
        color: Color(hex: "#BF5AF2"),
        conditions: ["Anxiety", "Depression", "PTSD", "Migraines"]
    )
]

struct ConditionView: View {
    @Binding var selected: Set<String>
    var onContinue: () -> Void
    @State private var expanded: Set<String> = ["resp"]

    var body: some View {
        ZStack {
            Color.obBg.ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("What public health conditions apply to you?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.obNavy)
                    Text("ENDO weights your signals around what matters most for your health.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.obSlate)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 1) {
                        ForEach(conditionCategories) { cat in
                            ConditionCategoryBlock(
                                category: cat,
                                isExpanded: expanded.contains(cat.id),
                                selected: $selected,
                                toggleExpand: {
                                    if expanded.contains(cat.id) {
                                        expanded.remove(cat.id)
                                    } else {
                                        expanded.insert(cat.id)
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

private struct ConditionCategoryBlock: View {
    let category: CondCat
    let isExpanded: Bool
    @Binding var selected: Set<String>
    let toggleExpand: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggleExpand) {
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(category.color)
                        .frame(width: 4, height: 22)
                    Text(category.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.obNavy)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.obSlate)
                }
                .padding(14)
                .background(.white)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(category.conditions, id: \.self) { cond in
                        let key = "\(category.id)_\(cond)"
                        Button {
                            if selected.contains(key) {
                                selected.remove(key)
                            } else {
                                selected.insert(key)
                            }
                        } label: {
                            HStack {
                                Image(systemName: selected.contains(key) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected.contains(key) ? category.color : Color.obMuted)
                                Text(cond)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.obNavy)
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 10)
                .background(Color.obBg.opacity(0.5))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.black.opacity(0.06), lineWidth: 0.5)
        )
        .padding(.bottom, 8)
    }
}
