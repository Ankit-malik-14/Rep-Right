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
        NavigationStack {
            // Fetched from SummaryDataModel: filter to exercises that have form accuracy recorded
            let recordsWithAccuracy = summaryManager.completedExercises
                .filter { $0.formAccuracy != nil }
                .sorted { $0.date > $1.date }
            
            List {
                if recordsWithAccuracy.isEmpty {
                    ContentUnavailableView("No Accuracy Data", systemImage: "gauge.with.dots.needle.bottom.50percent", description: Text("Use AI Assistance during a workout to get accuracy scores"))
                } else {
                    Section {
                        ForEach(recordsWithAccuracy) { record in
                            // Fetched from DataModel: resolve exerciseId to Exercise name and targetArea
                            let exerciseName = exercises.exerciseList.first(where: { $0.id == record.exerciseId })?.name ?? "Unknown"
                            let targetMuscle = exercises.exerciseList.first(where: { $0.id == record.exerciseId })?.targetAreas.first ?? "--"
                            let accuracy = Int(record.formAccuracy ?? 0)
                            
                            ZStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exerciseName)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        HStack(spacing: 12) {
                                            Text(targetMuscle)
                                            // Fetched from SummaryDataModel: record.date formatted as relative
                                            Text(record.date, format: .relative(presentation: .named))
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(accuracy)%")
                                        .font(.headline)
                                        .foregroundStyle(.orange)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.orange)
                                        .font(.subheadline.weight(.semibold))
                                }
                                .padding(.vertical, 4)
                                NavigationLink(destination: AccuracyMeterView(value: record.formAccuracy ?? 0, exerciseName: exerciseName)) {
                                    EmptyView()
                                }
                                .opacity(0.01)
                            }
                            .padding(.vertical, 4)
                            NavigationLink(destination: AccuracyMeterView(staticValue: 32.0)) {
                                EmptyView()
                            }
                            .opacity(0.01)

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
}

#Preview {
    ExerciseAccuracyListView()
        .environment(WorkoutSummaryManager())
        .environment(Exercises())
}
