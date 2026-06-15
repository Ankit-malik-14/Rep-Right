//
//  PreWorkoutGateViewModel.swift
//  Rep-Right
//
//  Created by Antigravity on 13/06/26.
//

import Foundation
import Observation

@Observable
class PreWorkoutGateViewModel {
    let preset: Preset
    private(set) var summaryManager: WorkoutSummaryManager
    private(set) var exercises: Exercises
    
    init(preset: Preset, summaryManager: WorkoutSummaryManager, exercises: Exercises) {
        self.preset = preset
        self.summaryManager = summaryManager
        self.exercises = exercises
    }
    
    var recoveryWarnings: [(muscle: String, hoursRemaining: Double)] {
        summaryManager.muscleRecoveryStatus(for: preset, using: exercises.exerciseList)
    }
    
    var smartPrepPreset: Preset {
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
}
