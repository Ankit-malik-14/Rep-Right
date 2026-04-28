//
//  DummyWorkoutSummaryData.swift
//  Rep_Right
//
//  Created by Jugad on 01/04/26.
//


import Foundation
import Observation

@Observable
class DummyWorkoutSummaryData {
    var manager: WorkoutSummaryManager
    
    init() {
        let dummyManager = WorkoutSummaryManager()
        dummyManager.currentUserWeight = 71.0
        
        let sampleExercises = Exercises().exerciseList
        let samplePresets = Presets().presets
        
        //IDs from the existing dummy data
        // used (??) nil-coalescing operator for fallback value uuid
        let pushUpId = sampleExercises.first(where: { $0.name == "Push-Up" })?.id ?? UUID()
        let squatId = sampleExercises.first(where: { $0.name == "Bodyweight Squat" })?.id ?? UUID()
        let rowId = sampleExercises.first(where: { $0.name == "Dumbbell Row" })?.id ?? UUID()
        let plankId = sampleExercises.first(where: { $0.name == "Plank" })?.id ?? UUID()
        
        let fullBodyPresetId = samplePresets.first(where: { $0.name == "Full Body Starter" })?.id ?? UUID()
        let upperFocusPresetId = samplePresets.first(where: { $0.name == "Upper Focus" })?.id ?? UUID()
        
        // Generating dates for testing Daily and Weekly grouping
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -8, to: today)!
        
        //a preset session: Today (Full Body)
        dummyManager.logWorkout(
            presetId: fullBodyPresetId,
            exercises: [
                (
                    exerciseId: pushUpId,
                    exerciseName: "Push-Up",
                    actualSet: [SetData(sets: 3, reps: 15)],
                    startTime: today,
                    endTime: today.addingTimeInterval(10 * 60),
                    caloriesBurned: nil,
                    formAccuracy: 84,
                    formInsights: ["Keep your core braced through the full rep.", "Lower with more control to keep your torso aligned."]
                ),
                (
                    exerciseId: squatId,
                    exerciseName: "Bodyweight Squat",
                    actualSet: [SetData(sets: 4, reps: 15)],
                    startTime: today.addingTimeInterval(12 * 60),
                    endTime: today.addingTimeInterval(25 * 60),
                    caloriesBurned: nil,
                    formAccuracy: 78,
                    formInsights: ["Drive your knees out slightly as you descend."]
                ),
                (
                    exerciseId: plankId,
                    exerciseName: "Plank",
                    actualSet: [SetData(sets: 3, reps: 60)],
                    startTime: today.addingTimeInterval(27 * 60),
                    endTime: today.addingTimeInterval(32 * 60),
                    caloriesBurned: nil,
                    formAccuracy: nil,
                    formInsights: nil
                )
            ]
        )
        
        //a standalone exercise: Yesterday
        dummyManager.logWorkout(presetId: nil, exercises: 
            [(exerciseId: pushUpId,
            exerciseName: "Push-Up",
            actualSet: [SetData(sets: 4, reps: 20)],
            startTime: yesterday,
            endTime: yesterday.addingTimeInterval(15 * 60),
            caloriesBurned: nil,
            formAccuracy: 91,
            formInsights: ["Excellent lockout. Maintain that shoulder position."])]
        )
        
        //a preset session: Two Days Ago (Upper Focus)
        dummyManager.logWorkout(
            presetId: upperFocusPresetId,
            exercises: [
                (
                    exerciseId: pushUpId,
                    exerciseName: "Push-Up",
                    actualSet: [SetData(sets: 3, reps: 12)],
                    startTime: twoDaysAgo,
                    endTime: twoDaysAgo.addingTimeInterval(8 * 60),
                    caloriesBurned: nil,
                    formAccuracy: 86,
                    formInsights: ["Keep your head neutral with your spine."]
                ),
                (
                    exerciseId: rowId,
                    exerciseName: "Dumbbell Row",
                    actualSet: [SetData(sets: 3, reps: 10)],
                    startTime: twoDaysAgo.addingTimeInterval(10 * 60),
                    endTime: twoDaysAgo.addingTimeInterval(20 * 60),
                    caloriesBurned: nil,
                    formAccuracy: 74,
                    formInsights: ["Pause briefly at the top to keep the shoulder blade engaged."]
                )
            ]
        )
        
        //inject an exercise to test Form Accuracy & Insights (Last Week)
        let manualRecord = CompletedExerciseRecord(
            id: UUID(),
            exerciseId: squatId,
            exerciseName: "Bodyweight Squat",
            presetId: nil,
            workoutSessionId: nil,
            date: lastWeek,
            startTime: lastWeek,
            endTime: lastWeek.addingTimeInterval(20 * 60),
            actualSet: [SetData(sets: 5, reps: 10)],
            formAccuracy: 88.5,
            formInsights: ["Great depth!", "Keep your chest up a bit more on the ascent."],
            caloriesBurnedValue: nil
        )
        dummyManager.completedExercises.append(manualRecord)
        
        self.manager = dummyManager
    }
}
