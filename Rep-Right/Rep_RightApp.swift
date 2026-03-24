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
    

//    @State var exercises = Exercise(name: "Deadlift", targetAreas: ["lower body"], equipments: ["dumbbell"], executionSteps: ["To do this i also don't know because i am not a gym enthusiast"], tips: ["do it carefully"], assistanceAvailable: true, setData: [])
    
    var body: some Scene {
        WindowGroup {
            UserProfileView()
                .environment(presets)
                .environment(exercises)
                .environment(weeklySchedules)
        }
    }
}
