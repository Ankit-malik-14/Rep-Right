//
//  Rep_RightApp.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-16.
//

import SwiftUI

@main
struct Rep_RightApp: App {
    var presets = Presets()
    var exercises = Exercises()
    var weeklySchedules = WeeklySchedules()
    var customPresetData = CustomPresetsDummyData()
    // Fetched from SummaryDataModel: Initialize global state manager
    var summaryManager = WorkoutSummaryManager() 
    var profileModel = UserProfileModel()
    
    var body: some Scene {
        WindowGroup {
            PostureCheckView(exercise: Exercise(
                name: "Push-Up",
                targetAreas: ["Chest", "Triceps", "Shoulders", "Core"],
                equipments: [],
                executionSteps: [
                    "Start in a high plank with hands slightly wider than shoulder-width.",
                    "Brace your core and keep a straight line from head to heels.",
                    "Lower your chest toward the floor by bending your elbows.",
                    "Press through your palms to return to the starting position."
                ],
                tips: [
                    "Keep elbows at ~45° from your torso.",
                    "Do not let hips sag; maintain a neutral spine.",
                    "Inhale on the way down, exhale as you press up."
                ],
                assistanceAvailable: true,
                demoVideo: URL(string: "https://example.com/videos/pushup.mp4"),
                setData: [
                    SetData(sets: 3, reps: 12),
                    SetData(sets: 1, reps: 10)
                ]
            ))
                .environment(presets)
                .environment(customPresetData)
                .environment(exercises)
                .environment(weeklySchedules)
                // Fetched from SummaryDataModel: Inject into environment
                .environment(summaryManager)
                // UPDATED: Removed deprecated DummyUserProfiles, keeping profileModel
                .environment(profileModel)
        }
    }
}

