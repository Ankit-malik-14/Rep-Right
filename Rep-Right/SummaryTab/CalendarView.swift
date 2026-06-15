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
        VStack(spacing: 18) {
            HStack {
                Button(action: { showCalendar.toggle() }) {
                    HStack(spacing: 4) {
                        Text(headerTitle)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.primary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 10) {
                    Button(action: { weekOffset -= 1; loadWeek() }) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.orange)
                            .frame(width: 34, height: 34)
                            .background(Color(.tertiarySystemFill), in: Circle())
                    }
                    .buttonStyle(.plain)
                    Button(action: { weekOffset += 1; loadWeek() }) {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.orange)
                            .frame(width: 34, height: 34)
                            .background(Color(.tertiarySystemFill), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)

            HStack {
                ForEach(weekData) { day in
                    DayView(day: day)
                }
            }
            .padding(.horizontal, 10)

            Divider().padding(.horizontal, 18)
        }
        .padding(.vertical, 18)
        .appCardStyle()
        .padding(.horizontal)
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

    // Access the Summary tab's view model
    @Environment(SummaryDashboardViewModel.self) private var viewModel

    func loadWeek() {
        let result = viewModel.loadWeek(offset: weekOffset)
        weekData = result.days
        headerTitle = result.monthYearHeader
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
                .background(day.status == "current" ? Color.orange : day.status == "streak" ? Color.orange.opacity(0.15) : Color(.tertiarySystemFill).opacity(day.status == "future" ? 0.6 : 0))
                .clipShape(Circle())
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CalendarView()
        .environment(WorkoutSummaryManager())
}
