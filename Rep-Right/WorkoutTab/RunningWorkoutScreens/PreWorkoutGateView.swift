import SwiftUI

struct PreWorkoutGateView: View {
    let preset: Preset

    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(Exercises.self) private var exercises
    @Environment(WorkoutRouter.self) private var router
    @Environment(\.dismiss) private var dismiss

    @State private var showSkipAlert = false

    private var recoveryWarnings: [(muscle: String, hoursRemaining: Double)] {
        summaryManager.muscleRecoveryStatus(
            for: preset, using: exercises.exerciseList
        )
    }
    
    private var smartPrepPreset: Preset {
        // On-the-fly logic to generate a warmup preset based on target areas
        let targetAreas = Set(preset.exercises.flatMap { $0.targetAreas })
        let warmupExercises = exercises.exerciseList.filter { 
            !Set($0.targetAreas).isDisjoint(with: targetAreas) 
        }
        return Preset(
            name: "Smart Prep: \(preset.name)",
            exercises: Array(warmupExercises.prefix(3)),
            isWarmpUp: true,
            scheduledFor: nil,
            estTime: 5,
            equipments: ["Bodyweight"],
            calories: 40
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recovery warning section
                if !recoveryWarnings.isEmpty {
                    RecoveryWarningCard(warnings: recoveryWarnings)
                } else {
                    AllClearCard()
                }
                // Smart prep section
                SmartPrepPromptCard(preset: preset, smartPrepPreset: smartPrepPreset)
            }
            .padding()
        }
        .navigationTitle("Before You Start")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Skip", role: .destructive) {
                    showSkipAlert = true
                }
                .tint(.red)
            }
        }
        .alert("Skip Smart Prep?", isPresented: $showSkipAlert) {
            Button("Start Workout", role: .destructive) {
                router.push(.activeWorkout(preset))
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Skipping your warmup increases the risk of injury. It's highly recommended to prepare your muscles first!")
        }
    }
}

// Dummy views for the components we need to build or find
struct RecoveryWarningCard: View {
    let warnings: [(muscle: String, hoursRemaining: Double)]
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Recovery Warning", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundColor(.yellow)
            Text("Some muscles are still recovering:")
                .font(.subheadline)
            ForEach(warnings, id: \.muscle) { warning in
                HStack {
                    Text(warning.muscle)
                    Spacer()
                    Text("\(Int(warning.hoursRemaining))h remaining")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AllClearCard: View {
    var body: some View {
        HStack {
            Label("All systems go 💪", systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SmartPrepPromptCard: View {
    let preset: Preset
    let smartPrepPreset: Preset
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Smart Prep", systemImage: "figure.mind.and.body")
                .font(.headline)
            Text("Warm up your \(preset.focousArea.joined(separator: ", ")) before you begin.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            NavigationLink(value: WorkoutRoute.activeWorkout(smartPrepPreset)) {
                Text("Start Smart Prep")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    // 1. Create a mock preset
    let mockPreset = Preset(
        name: "Full Body Blast",
        exercises: [],
        isWarmpUp: false,
        scheduledFor: nil,
        estTime: 45,
        equipments: ["Dumbbells"],
        calories: 300,
        
    )

    // 2. Inject environment objects and wrap in NavigationStack
    NavigationStack {
        PreWorkoutGateView(preset: mockPreset)
    }
    .environment(WorkoutSummaryManager())
    .environment(Exercises())
    .environment(WorkoutRouter())
}
