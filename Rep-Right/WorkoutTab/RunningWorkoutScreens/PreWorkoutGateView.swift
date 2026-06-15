import SwiftUI

struct PreWorkoutGateView: View {
    let preset: Preset

    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(Exercises.self) private var exercises
    @Environment(WorkoutRouter.self) private var router
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: PreWorkoutGateViewModel?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                PreWorkoutGateViewContent()
                    .environment(viewModel)
            } else {
                Color.clear
                    .onAppear {
                        viewModel = PreWorkoutGateViewModel(
                            preset: preset,
                            summaryManager: summaryManager,
                            exercises: exercises
                        )
                    }
            }
        }
    }
}

struct PreWorkoutGateViewContent: View {
    @Environment(PreWorkoutGateViewModel.self) private var viewModel
    @Environment(WorkoutRouter.self) private var router
    @Environment(\.dismiss) private var dismiss

    @State private var showSkipAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recovery warning section
                if !viewModel.recoveryWarnings.isEmpty {
                    RecoveryWarningCard(warnings: viewModel.recoveryWarnings)
                } else {
                    AllClearCard()
                }
                // Smart prep section
                SmartPrepPromptCard(preset: viewModel.preset, smartPrepPreset: viewModel.smartPrepPreset)
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
        .alert("Skip Warmup?", isPresented: $showSkipAlert) {
            Button("Start Workout", role: .destructive) {
                router.push(.activeWorkout(viewModel.preset))
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
            Label("You are ready to lift weight", systemImage: "checkmark.circle.fill")
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
            Label("Smart Warmup", systemImage: "figure.mind.and.body")
                .font(.headline)
            Text("Warm up your \(preset.focousArea.joined(separator: ", ")) before you begin.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            NavigationLink(value: WorkoutRoute.activeWorkout(smartPrepPreset)) {
                Text("Start Warmup")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding()
        .background(.secondary)
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
