//
//  WorkoutHomeViewModel.swift
//  Rep-Right
//
//  Created by Antigravity on 13/06/26.
//

import Foundation
import Observation

@Observable
class WorkoutHomeViewModel {
    private(set) var presets: Presets
    private(set) var exercises: Exercises
    private(set) var weeklySchedules: WeeklySchedules
    private(set) var summaryManager: WorkoutSummaryManager
    private(set) var userProfile: UserProfileModel
    
    init(presets: Presets, exercises: Exercises, weeklySchedules: WeeklySchedules, summaryManager: WorkoutSummaryManager, userProfile: UserProfileModel) {
        self.presets = presets
        self.exercises = exercises
        self.weeklySchedules = weeklySchedules
        self.summaryManager = summaryManager
        self.userProfile = userProfile
    }
    
    // MARK: - Seeding
    
    func seedSuggestedWorkoutIfNeeded() {
        guard summaryManager.completedExercises.isEmpty else { return }
        guard let today = Weekday(rawValue: Calendar.current.component(.weekday, from: Date())) else { return }
        guard weeklySchedules.schedules[today] == nil else { return }
        
        let recommendations = summaryManager.recommendedPresets(from: presets.presets, using: exercises.exerciseList)
        if let bestPreset = recommendations.first?.preset {
            var scheduledPreset = bestPreset
            scheduledPreset.scheduledFor = today
            weeklySchedules.schedules[today] = scheduledPreset
        }
    }
    
    // MARK: - Recommendations & Recovery
    
    var recommendations: [PresetRecommendation] {
        summaryManager.recommendedPresets(from: presets.presets, using: exercises.exerciseList)
    }
    
    var recommendedSchedule: [ScheduledPresetRecommendation] {
        summaryManager.generatedWeeklySchedule(
            from: presets.presets,
            using: exercises.exerciseList,
            trainingDays: userProfile.weeklyGoalDays
        )
    }
    
    var todaySchedule: Preset? {
        guard let today = Weekday(rawValue: Calendar.current.component(.weekday, from: Date())) else { return nil }
        return weeklySchedules.schedules[today]
    }
}
