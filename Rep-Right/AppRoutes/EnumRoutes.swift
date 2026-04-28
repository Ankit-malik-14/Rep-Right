//
//  EnumRoutes.swift
//  Rep_Right
//
//  Created by Jugad on 25/04/26.
//

import Foundation

// MARK: - Workout Tab Routes

enum WorkoutRoute: Hashable {
    // Expanded list views
    case defaultPresetsList
    case customPresetsList
    case exerciseList

    // Detail views
    case presetDetail(Preset)
    case exerciseDetail(Exercise)

    // Pre-workout flow
    case preWorkoutGate(Preset)

    // Active workout
    case activeWorkout(Preset)

    // Profile
    case profile
}

// MARK: - Summary Tab Routes

enum SummaryRoute: Hashable {
    case calorieBreakdown
    case metricRing
    case userCalorieIntake
    case exerciseAccuracyList
    case accuracyMeter(value: Double, exerciseName: String, insights: [String])
    case profile
}
