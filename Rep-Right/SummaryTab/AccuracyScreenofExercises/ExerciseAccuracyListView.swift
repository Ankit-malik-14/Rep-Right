import SwiftUI

struct ExerciseModel: Identifiable {
    let id = UUID()
    var name: String
    let targetMuscle: String
    let timeAgo: String
    let accuracy: Int
}

struct ExerciseAccuracyListView: View {
    // Fetched from SummaryDataModel: completed exercises with form accuracy data
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    // Fetched from DataModel: exercise catalog to resolve exerciseId → name/target
    @Environment(Exercises.self) private var exercises

    var body: some View {
        // Precompute records with accuracy to help the compiler
        let all = summaryManager.completedExercises
        let filtered = all.filter { $0.formAccuracy != nil }
        let recordsWithAccuracy = filtered.sorted { lhs, rhs in
            lhs.date > rhs.date
        }

        List {
            if recordsWithAccuracy.isEmpty {
                ContentUnavailableView(
                    "No Accuracy Data",
                    systemImage: "gauge.with.dots.needle.bottom.50percent",
                    description: Text("Use AI Assistance during a workout to get accuracy scores")
                )
            } else {
                Section {
                    ForEach(recordsWithAccuracy) { record in
                        let exercise = exercises.exerciseList.first(where: { $0.id == record.exerciseId })
                        let exerciseName = exercise?.name ?? "Unknown"
                        let targetMuscle = exercise?.targetAreas.first ?? "--"
                        let accuracy = Int(record.formAccuracy ?? 0)

                        NavigationLink(value: SummaryRoute.accuracyMeter(value: record.formAccuracy ?? 0, exerciseName: exerciseName)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exerciseName)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)

                                    HStack(spacing: 12) {
                                        Text(targetMuscle)
                                        Text(record.date, format: .relative(presentation: .named))
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text("\(accuracy)%")
                                    .font(.headline)
                                    .foregroundStyle(.orange)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Recent")
                        .textCase(.none)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Exercise History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ExerciseAccuracyListView()
        .environment(WorkoutSummaryManager())
        .environment(Exercises())
}
