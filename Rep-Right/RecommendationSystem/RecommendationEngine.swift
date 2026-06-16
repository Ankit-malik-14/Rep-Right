//
//  RecommendationEngine.swift
//  Rep_Right
//
//  Created by Jugad on 06/04/26.
//

import Foundation

struct RecoveryFocusSnapshot: Identifiable, Hashable {
    var id: FocusArea { focusArea }
    let focusArea: FocusArea
    let weeklyLoad: Int
    let recentLoad: Int
    let lastTrainedAt: Date?
    let recoveryHoursRemaining: Double
    let status: FocusAreaLoadStatus
    
    var loadLimit: Int { 12 }
    
    var guidance: String {
        if status == .overtrained {
            if recoveryHoursRemaining > 0 {
                return "Rest for \(Int(recoveryHoursRemaining.rounded(.up))) more hours and target other muscles."
            }
            return "Optimal weekly volume exceeded. Focus on other muscle groups."
        }
        
        if status == .onTrack {
            if recoveryHoursRemaining > 0 {
                return "Training target met, but allow more recovery time before working this group again."
            }
            return "Ideal training range. Keep this group in regular rotation."
        }
        
        if weeklyLoad == 0 {
            return "Fully recovered. Ready for your next workout."
        }
        
        return "Light training volume. You can safely add more exercises here."
    }
}

struct PresetRecommendation: Identifiable, Hashable {
    let preset: Preset
    let score: Int
    let primaryFocusAreas: [FocusArea]
    let recoveringFocusAreas: [FocusArea]
    let headline: String
    let reason: String
    
    var id: UUID { preset.id }
}

struct ScheduledPresetRecommendation: Identifiable, Hashable {
    let weekday: Weekday
    let preset: Preset
    let note: String
    
    var id: Int { weekday.rawValue }
}

extension WorkoutSummaryManager {
    func recoveryMap(using catalog: [Exercise], now: Date = Date()) -> [RecoveryFocusSnapshot] {
        recommendationService.recoveryMap(completedExercises: completedExercises, using: catalog, now: now)
    }
    
    func recommendedPresets(
        from presets: [Preset],
        using catalog: [Exercise],
        now: Date = Date(),
        limit: Int = 3
    ) -> [PresetRecommendation] {
        recommendationService.recommendedPresets(completedExercises: completedExercises, from: presets, using: catalog, now: now, limit: limit)
    }
    
    func generatedWeeklySchedule(
        from presets: [Preset],
        using catalog: [Exercise],
        trainingDays: Int,
        now: Date = Date()
    ) -> [ScheduledPresetRecommendation] {
        recommendationService.generatedWeeklySchedule(completedExercises: completedExercises, from: presets, using: catalog, trainingDays: trainingDays, now: now)
    }
    
    func overtrainedFocusAreas(using catalog: [Exercise], now: Date = Date()) -> [RecoveryFocusSnapshot] {
        recommendationService.overtrainedFocusAreas(completedExercises: completedExercises, using: catalog, now: now)
    }
}

