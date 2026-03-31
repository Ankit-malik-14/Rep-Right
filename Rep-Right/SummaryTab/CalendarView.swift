import SwiftUI

enum DayStatus {
    case streak
    case current
    case missed
    case future
}

struct WorkoutDay: Identifiable {
    let id = UUID()
    let name: String
    let number: String
    let status: DayStatus
}

struct CalendarView: View {
    @State private var weekData: [WorkoutDay] = []
    
    // MARK: - Navigation State
    @State private var weekOffset: Int = 0
    @State private var showMonthCalendar: Bool = false
    @State private var displayedMonthYear: String = ""
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Header
            HStack {
                // Button to open Monthly Calendar
                Button(action: {
                    showMonthCalendar.toggle()
                }) {
                    HStack(spacing: 4) {
                        Text(displayedMonthYear)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                            // Optional: Rotate chevron when pressed
                            .rotationEffect(.degrees(showMonthCalendar ? 90 : 0))
                            .animation(.easeInOut, value: showMonthCalendar)
                    }
                }
                
                Spacer()
                
                // Week Navigation Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        weekOffset -= 1
                        generateWeek()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                    }
                    
                    Button(action: {
                        weekOffset += 1
                        generateWeek()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(.horizontal)
            
            // MARK: - Week Days
            HStack {
                ForEach(weekData) { day in
                    Spacer()
                    DayView(day: day)
                    Spacer()
                }
            }
            
            Divider()
                .padding(.top, 8)
                .padding(.horizontal)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
        .background(.white)
        .onAppear {
            generateWeek() // Generate initial week on load
        }
        // Monthly Calendar view using DatePicker
        .sheet(isPresented: $showMonthCalendar) {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .onChange(of: selectedDate) { oldValue, newValue in
                        updateWeekOffset(for: newValue)
                        showMonthCalendar = false
                    }
                Spacer()
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Date Generation Logic
    private func generateWeek() {
        var days: [WorkoutDay] = []
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate the target date based on the week offset
        guard let targetWeekDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today),
              let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: targetWeekDate)) else {
            return
        }
        
        // Update the header title (e.g., "April 2025")
        displayedMonthYear = targetWeekDate.formatted(.dateTime.month(.wide).year())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE" // "SUN", "MON", etc.
        
        // Generate 7 days starting from Sunday
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let name = dateFormatter.string(from: date).uppercased()
                let number = String(calendar.component(.day, from: date))
                
                let status: DayStatus
                
                if calendar.isDateInToday(date) {
                    status = .current
                } else if date > today {
                    status = .future
                } else {
                    // PLACEHOLDER: Assigning streak vs missed for past days.
                    status = i % 2 == 0 ? .missed : .streak
                }
                
                days.append(WorkoutDay(name: name, number: number, status: status))
            }
        }
        
        // Animate the update so it slides smoothly
        withAnimation(.easeInOut) {
            self.weekData = days
        }
    }
    
    // MARK: - Offset Calculation
    private func updateWeekOffset(for date: Date) {
        let calendar = Calendar.current
        let today = Date()
        
        guard let startOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let startOfSelectedWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return
        }
        
        let components = calendar.dateComponents([.day], from: startOfCurrentWeek, to: startOfSelectedWeek)
        if let days = components.day {
            withAnimation(.easeInOut) {
                weekOffset = days / 7
                generateWeek()
            }
        }
    }
}

// MARK: - Supporting View

struct DayView: View {
    let day: WorkoutDay
    
    var body: some View {
        VStack(spacing: 12) {
            Text(day.name)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
            
            Text(day.number)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(textColor)
                .frame(width: 44, height: 44)
                .background(backgroundColor)
                .clipShape(Circle())
        }
    }
    
    var textColor: Color {
        switch day.status {
        case .streak, .missed: return .orange
        case .current: return .white
        case .future: return .black
        }
    }
    
    var backgroundColor: Color {
        switch day.status {
        case .streak: return .orange.opacity(0.15)
        case .current: return .orange
        case .missed, .future: return .clear
        }
    }
}

#Preview {
    CalendarView()
}

