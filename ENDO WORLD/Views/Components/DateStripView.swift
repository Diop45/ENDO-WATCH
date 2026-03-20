import SwiftUI

struct DateStripView: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.current
    private var weekDates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (-3...3).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }

    private func dayLabel(_ date: Date) -> String {
        if calendar.isDateInToday(date) { return "Today" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(weekDates, id: \.self) { date in
                        Button(action: { selectedDate = date }) {
                            VStack(spacing: 4) {
                                Text(dayLabel(date))
                                    .font(.system(size: 12, weight: calendar.isDate(date, inSameDayAs: selectedDate) ? .semibold : .regular))
                                    .foregroundStyle(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.endoCyan : .white.opacity(0.6))
                                Text(shortDate(date))
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.endoCyan.opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .id(date)
                    }
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                proxy.scrollTo(calendar.startOfDay(for: Date()), anchor: .center)
            }
        }
        .padding(.vertical, 8)
    }
}
