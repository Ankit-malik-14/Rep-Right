import SwiftUI

struct WorkoutDay: Identifiable {
    let id = UUID()
    let name: String
    let number: String
    let status: String // "streak", "current", "missed", "future"
}

struct CalendarView: View {
    @State private var weekData: [WorkoutDay] = []
    @State private var weekOffset = 0
    @State private var showCalendar = false
    @State private var headerTitle = ""
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { showCalendar.toggle() }) {
                    HStack(spacing: 4) {
                        Text(headerTitle)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.gray)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                }

                Spacer()

                HStack(spacing: 20) {
                    Button(action: { weekOffset -= 1; loadWeek() }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.orange)
                    }
                    Button(action: { weekOffset += 1; loadWeek() }) {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(.horizontal)

            HStack {
                ForEach(weekData) { day in
                    Spacer()
                    DayView(day: day)
                    Spacer()
                }
            }

            Divider().padding(.horizontal)
        }
        .padding(.vertical, 20)
        .onAppear { loadWeek() }
        .sheet(isPresented: $showCalendar) {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .onChange(of: selectedDate) { _, newDate in
                        let calendar = Calendar.current
                        let today = Date()
                        let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                        let selectedWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: newDate))!
                        let diff = calendar.dateComponents([.day], from: currentWeekStart, to: selectedWeekStart).day ?? 0
                        weekOffset = diff / 7
                        loadWeek()
                        showCalendar = false
                    }
                Spacer()
            }
            .presentationDetents([.medium, .large])
        }
    }

    func loadWeek() {
        let calendar = Calendar.current
        let today = Date()

        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today),
              let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: targetDate)) else { return }

        headerTitle = targetDate.formatted(.dateTime.month(.wide).year())

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        var days: [WorkoutDay] = []
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: weekStart)!
            let name = formatter.string(from: date).uppercased()
            let number = "\(calendar.component(.day, from: date))"

            let status: String
            if calendar.isDateInToday(date) {
                status = "current"
            } else if date > today {
                status = "future"
            } else {
                status = i % 2 == 0 ? "missed" : "streak"
            }

            days.append(WorkoutDay(name: name, number: number, status: status))
        }

        weekData = days
    }
}

struct DayView: View {
    let day: WorkoutDay

    var body: some View {
        VStack(spacing: 12) {
            Text(day.name)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(day.number)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(day.status == "current" || day.status == "future" ? Color.primary : Color.orange)
                .frame(width: 44, height: 44)
                .background(day.status == "current" ? Color.orange : day.status == "streak" ? Color.orange.opacity(0.15) : Color.clear)
                .clipShape(Circle())
        }
    }
}

#Preview {
    CalendarView()
}
