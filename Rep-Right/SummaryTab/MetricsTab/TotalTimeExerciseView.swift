import SwiftUI
import Charts

struct TotalTimeExerciseView: View {
    // Fetched from SummaryDataModel: weekly activity by day
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    // Fetched from DataModel: exercise catalog to resolve exerciseId → targetAreas
    @Environment(Exercises.self) private var exercises

    let categoryColors: [String: Color] = [
        "Chest":    Color(red: 228/255, green: 59/255, blue: 55/255),
        "Back":     Color(red: 22/255, green: 176/255, blue: 221/255),
        "Lats":     Color(red: 22/255, green: 176/255, blue: 221/255),
        "Core":     Color(red: 247/255, green: 188/255, blue: 36/255),
        "Quads":    Color(red: 104/255, green: 199/255, blue: 79/255),
        "Glutes":   Color(red: 104/255, green: 199/255, blue: 79/255),
        "Shoulders": Color(red: 253/255, green: 147/255, blue: 29/255),
        "Triceps":  Color(red: 253/255, green: 147/255, blue: 29/255)
    ]

    var body: some View {
        // Fetched from SummaryDataModel: weeklyActivityByDay mapped from completed records
        let stats = summaryManager.weeklyActivityByDay(using: exercises.exerciseList)
        let maxMinutes = stats.map { $0.minutes }.max() ?? 60

        VStack(alignment: .leading, spacing: 20) {

            Text("Weekly Activity")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            if stats.isEmpty {
                ContentUnavailableView("No Activity Yet", systemImage: "chart.bar", description: Text("Complete workouts this week to see your activity"))
                    .frame(height: 300)
            } else {
                Chart(stats, id: \.day) { stat in
                    BarMark(
                        x: .value("Day", stat.day),
                        y: .value("Minutes", stat.minutes)
                    )
                    .foregroundStyle(categoryColors[stat.category] ?? .orange)
                    .cornerRadius(6)
                }
                .chartYScale(domain: 0...max(60, maxMinutes))
                .frame(height: 300)
                .padding()
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }

            Spacer()
        }
    }
}

#Preview {
    TotalTimeExerciseView()
        .environment(WorkoutSummaryManager())
        .environment(Exercises())
}
