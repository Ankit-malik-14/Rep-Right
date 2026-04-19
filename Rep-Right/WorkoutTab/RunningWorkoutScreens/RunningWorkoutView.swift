/* DEPRECATED: Replaced by ActiveWorkoutView. Logic moved to WorkoutSessionManager for a robust state-machine architecture.
//
//  RunningWorkoutView.swift
//  Rep-Right
//

import SwiftUI
import Observation

@Observable
class ActiveWorkoutState {
    var preset: Preset
    var currentExerciseIndex: Int = 0
    var timeElapsed: TimeInterval = 0
    var timer: Timer?
    var isTimerRunning = false
    var isFinished = false
    
    init(preset: Preset) {
        self.preset = preset
    }
    
    var currentExercise: Exercise? {
        guard preset.exercises.indices.contains(currentExerciseIndex) else { return nil }
        return preset.exercises[currentExerciseIndex]
    }
    
    func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timeElapsed += 1
        }
    }
    func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
    }
    func stopTimer() {
        pauseTimer()
        timeElapsed = 0
    }
    /// Whether the user is currently on the last exercise in the preset
    var isOnLastExercise: Bool {
        currentExerciseIndex >= preset.exercises.count - 1
    }
    
    func nextExercise() {
        if currentExerciseIndex < preset.exercises.count - 1 {
            currentExerciseIndex += 1
        }
    }
    
    /// Marks the full preset workout as complete, stops the timer, and sets progress to 100%
    func finishWorkout() {
        isFinished = true
        pauseTimer()
    }
    
    /// Progress through workout (0.0–1.0) based on current exercise index
    var progress: Double {
        guard preset.exercises.count > 0 else { return 0 }
        if isFinished { return 1.0 }
        return Double(currentExerciseIndex) / Double(preset.exercises.count)
    }
    
    /// Estimated calories burned so far using MET 5.0 formula
    func estimatedCalories(userWeightKg: Double) -> Int {
        let timeInHours = timeElapsed / 3600.0
        return Int(5.0 * userWeightKg * timeInHours)
    }
}

struct RunningWorkoutView: View {
    var preset: Preset
    @State private var workoutState: ActiveWorkoutState
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(\.userProfile) private var userProfile
    
    init(preset: Preset) {
        self.preset = preset
        self._workoutState = State(initialValue: ActiveWorkoutState(preset: preset))
    }
    
    var body: some View {
        VStack {
            // Fetched from ActiveWorkoutState: timeElapsed, progress, estimated calories
            DataLabels(
                timeElapsed: workoutState.timeElapsed,
                progress: workoutState.progress,
                calories: workoutState.estimatedCalories(userWeightKg: Double(userProfile?.weight ?? 71))
            )
                .padding()
            ImageAndInfoCard(exercise: workoutState.currentExercise)
                .padding(3)
            RunningWorkoutInfo(workoutState: workoutState)
                .padding(3)
        }
        .onAppear {
            workoutState.startTimer()
        }
        .onDisappear {
            workoutState.pauseTimer()
        }
        .onChange(of: workoutState.isFinished) { _, finished in
            if finished {
                // Log the completed preset session
                let weight = Double(userProfile?.weight ?? 71)
                let exerciseData = preset.exercises.map { exercise in
                    let cals = summaryManager.calculateCalories(
                        for: exercise,
                        durationInSeconds: workoutState.timeElapsed / Double(max(preset.exercises.count, 1)),
                        weightInKg: weight
                    )
                    return (
                        exerciseId: exercise.id,
                        actualSet: exercise.setData,
                        startTime: Date().addingTimeInterval(-workoutState.timeElapsed),
                        endTime: Date(),
                        caloriesBurned: Optional(cals)
                    )
                }
                summaryManager.logPresetSession(presetId: preset.id, exercises: exerciseData)
                
                // Dismiss back to home after a brief moment to show 100%
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
}
*/
