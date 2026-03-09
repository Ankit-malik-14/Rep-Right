import SwiftUI

struct CalendarStripView: View {

    @State private var selectedDate: Date = .now
    @State private var weekOffset: Int = 0

    private let calendar = Calendar.current

    // Days that have activity (hardcoded offsets from start of current week)
    private let activeDayOffsets: Set<Int> = [1, 2, 3]

    /// Dates for the displayed week
    private var weekDates: [Date] {
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: referenceDate)?.start else {
            return []
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    /// The reference date shifted by weekOffset
    private var referenceDate: Date {
        calendar.date(byAdding: .weekOfYear, value: weekOffset, to: .now) ?? .now
    }

    /// Month-year label from DateFormatter
    private var monthYearLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: referenceDate)
    }

    /// Short day symbol (SUN, MON, …)
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    /// Day number
    private func dayNumber(for date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    /// Check if two dates are the same calendar day
    private func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Month row
            HStack(spacing: 6) {
                Text(monthYearLabel)
                    .font(.subheadline.weight(.semibold))

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button { weekOffset -= 1 } label: {
                    Image(systemName: "chevron.left")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Button { weekOffset += 1 } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            // Day strip
            HStack(spacing: 0) {
                ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                    let isSelected = isSameDay(date, selectedDate)
                    let isActive = activeDayOffsets.contains(index)

                    VStack(spacing: 6) {
                        Text(dayLabel(for: date))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)

                        ZStack {
                            if isSelected {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 36, height: 36)
                            }

                            Text("\(dayNumber(for: date))")
                                .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? .white : .primary)
                        }
                        .frame(width: 36, height: 36)

                        // Activity dot
                        Circle()
                            .fill(isActive && !isSelected ? Color.orange : Color.clear)
                            .frame(width: 5, height: 5)
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDate = date
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    CalendarStripView()
        .background(Color(.systemGroupedBackground))
}
