//
//  SchedulerViewModel.swift
//  Rep-Right
//
//  Created by Antigravity on 13/06/26.
//

import Foundation
import Observation

@Observable
class SchedulerViewModel {
    private(set) var weeklySchedules: WeeklySchedules
    private(set) var summaryManager: WorkoutSummaryManager
    private(set) var presets: Presets
    private(set) var exercises: Exercises
    private(set) var userProfile: UserProfileModel
    
    init(
        weeklySchedules: WeeklySchedules,
        summaryManager: WorkoutSummaryManager,
        presets: Presets,
        exercises: Exercises,
        userProfile: UserProfileModel
    ) {
        self.weeklySchedules = weeklySchedules
        self.summaryManager = summaryManager
        self.presets = presets
        self.exercises = exercises
        self.userProfile = userProfile
    }
    
    // MARK: - Properties & Computed State
    
    var recommendedSchedule: [ScheduledPresetRecommendation] {
        summaryManager.generatedWeeklySchedule(
            from: presets.presets,
            using: exercises.exerciseList,
            trainingDays: userProfile.weeklyGoalDays
        )
    }
    
    func preset(for weekday: Weekday) -> Preset? {
        weeklySchedules.schedules[weekday]
    }
    
    // MARK: - Actions
    
    func applySmartSchedule() {
        weeklySchedules.apply(recommendedSchedule)
    }
    
    func assignPreset(_ preset: Preset?, for weekday: Weekday) {
        if let preset = preset {
            weeklySchedules.schedules[weekday] = preset
        } else {
            weeklySchedules.schedules.removeValue(forKey: weekday)
        }
    }
    
    func updatePreset(_ preset: Preset, for weekday: Weekday) {
        weeklySchedules.schedules.updateValue(preset, forKey: weekday)
    }
    
    func toggleRestDay(for weekday: Weekday, isRest: Bool) {
        if isRest {
            if let recoveryPreset = weeklySchedules.schedules[weekday], recoveryPreset.isRestDay {
                return
            }
            if let activeRecovery = presets.presets.first(where: { $0.isRestDay }) {
                weeklySchedules.schedules[weekday] = activeRecovery
            }
        } else {
            if let currentPreset = weeklySchedules.schedules[weekday], currentPreset.isRestDay {
                weeklySchedules.schedules.removeValue(forKey: weekday)
            }
        }
    }
    
    // MARK: - Business Logic (Rest Day Tips)
    
    func restDayTips(for weekday: Weekday) -> [String] {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterdayRecords = summaryManager.completedExercises.filter { calendar.isDate($0.date, inSameDayAs: yesterday) }
        
        var trainedMuscles: Set<String> = []
        for record in yesterdayRecords {
            if let ex = exercises.exerciseList.first(where: { $0.id == record.exerciseId }) {
                for area in ex.targetAreas {
                    trainedMuscles.insert(area)
                }
            }
        }
        
        var tips = [
            "Hydrate well to flush out metabolic waste.",
            "Aim for 8-9 hours of sleep tonight to maximize recovery."
        ]
        
        if !trainedMuscles.isEmpty {
            let musclesStr = trainedMuscles.prefix(2).joined(separator: " and ")
            tips.insert("Light walking is fine, but avoid heavy loading on your \(musclesStr.lowercased()) today.", at: 0)
        } else {
            tips.insert("A 15-minute mobility flow or stretching session is perfect for today.", at: 0)
        }
        
        return tips
    }
}
