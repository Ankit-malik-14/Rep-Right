//
//  Rep_RightApp.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-16.
//

import SwiftUI
import SwiftData

@main
struct Rep_RightApp: App {
    var presets = Presets()
    var exercises = Exercises()
    var weeklySchedules = WeeklySchedules()
    var customPresetData = CustomPresetsDummyData()
    // Fetched from SummaryDataModel: Initialize global state manager
    var summaryManager = WorkoutSummaryManager() 
    var profileModel = UserProfileModel()
    let sharedModelContainer: ModelContainer
    
    init() {
        do {
            sharedModelContainer = try ModelContainer(for: PersistedAppState.self)
            try PersistenceController.shared.configure(
                container: sharedModelContainer,
                summaryManager: summaryManager,
                weeklySchedules: weeklySchedules,
                customPresets: customPresetData,
                profileModel: profileModel
            )
        } catch {
            fatalError("Failed to configure SwiftData persistence: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            //JointModelTestScreen()
            HomeView()
                .environment(presets)
                .environment(customPresetData)
                .environment(exercises)
                .environment(weeklySchedules)
                // Fetched from SummaryDataModel: Inject into environment
                .environment(summaryManager)
                // UPDATED: Removed deprecated DummyUserProfiles, keeping profileModel
                .environment(profileModel)
                .modelContainer(sharedModelContainer)
        }
    }
}
