import SwiftUI
import Charts

struct TotalTimeExerciseView: View {

    let moveRed = Color(red: 228/255, green: 59/255, blue: 55/255)
    let exerciseGreen = Color(red: 104/255, green: 199/255, blue: 79/255)
    let standBlue = Color(red: 22/255, green: 176/255, blue: 221/255)
    let eggYolkYellow = Color(red: 247/255, green: 188/255, blue: 36/255)
    let shinyOrange = Color(red: 253/255, green: 147/255, blue: 29/255)

    var body: some View {

        let stats: [(day: String, category: String, minutes: Double, color: Color)] = [
            ("Mon", "Chest",    50, moveRed),
            ("Tue", "Leg",      45, exerciseGreen),
            ("Wed", "Core",     30, eggYolkYellow),
            ("Thu", "Chest",    42, moveRed),
            ("Fri", "Back",     35, standBlue),
            ("Sat", "Shoulder", 25, shinyOrange)
        ]

        let maxMinutes = stats.map { $0.minutes }.max() ?? 60

        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {

                Text("Weekly Activity")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Chart(stats, id: \.day) { stat in
                    BarMark(
                        x: .value("Day", stat.day),
                        y: .value("Minutes", stat.minutes)
                    )
                    .foregroundStyle(stat.color)
                    .cornerRadius(6)
                }
                .chartYScale(domain: 0...max(60, maxMinutes))
                .frame(height: 300)
                .padding()
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)

                Spacer()
            }
        }
    }
}

#Preview {
    TotalTimeExerciseView()
}

