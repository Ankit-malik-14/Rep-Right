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
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(presets)
                .environment(customPresetData)
                .environment(exercises)
                .environment(weeklySchedules)
        }
    }
}
