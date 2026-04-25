import SwiftUI
import Charts

struct ExerciseRingView: View {
    // Fetched from SummaryDataModel: exercise breakdown by target area
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    // Fetched from DataModel: exercise catalog to resolve exerciseId → targetAreas
    @Environment(Exercises.self) private var exercises

    let ringColors: [String: Color] = [
        FocusArea.back.rawValue: Color(red: 22/255, green: 176/255, blue: 221/255),
        FocusArea.chest.rawValue: Color(red: 228/255, green: 59/255, blue: 55/255),
        FocusArea.legs.rawValue: Color(red: 104/255, green: 199/255, blue: 79/255),
        FocusArea.core.rawValue: Color(red: 247/255, green: 188/255, blue: 36/255),
        FocusArea.shoulder.rawValue: Color(red: 253/255, green: 147/255, blue: 29/255),
        FocusArea.arms.rawValue: Color(red: 160/255, green: 90/255, blue: 220/255)
    ]

    var body: some View {
        // Fetched from SummaryDataModel: exercisesByTargetArea grouped from completed records
        let stats = summaryManager.exercisesByTargetArea(using: exercises.exerciseList)
        let total = stats.reduce(0.0) { $0 + $1.value }

        VStack(spacing: 40) {

            Text("Total Exercises")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            if stats.isEmpty {
                ContentUnavailableView("No Exercises Yet", systemImage: "dumbbell", description: Text("Complete workouts to see your breakdown"))
            } else {
                Chart(Array(stats.enumerated()), id: \.element.category) { index, stat in
                    SectorMark(
                        angle: .value("Exercises", stat.value),
                        innerRadius: .ratio(0.7),
                        angularInset: 2.0
                    )
                    .foregroundStyle(by: .value("Category", stat.category))
                    .cornerRadius(6)
                }
                .chartForegroundStyleScale(
                    domain: stats.map { $0.category },
                    range: stats.map { ringColors[$0.category] ?? .gray }
                )
                .chartLegend(position: .bottom, alignment: .center)
                .frame(width: 250, height: 250)
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        if let plotFrame = chartProxy.plotFrame {
                            let frame = geometry[plotFrame]
                            VStack {
                                Text("Total")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(Int(total), format: .number)
                                    .font(.system(size: 38, weight: .bold, design: .rounded))
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ExerciseRingView()
        .environment(WorkoutSummaryManager())
        .environment(Exercises())
}
