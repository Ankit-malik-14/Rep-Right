//
//  ActiveOnboardingViewModel.swift
//  Rep-Right
//
//  Created by Antigravity on 15/06/26.
//

import Foundation
import Observation

@Observable
class ActiveOnboardingViewModel {
    // Current step
    var currentStep: OnboardingStep = .welcome
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case measurements = 1
        case goals = 2
        case tutorial = 3
        case success = 4
    }
    
    // Step 1: Baseline Measurements
    var unitSystem: UnitSystem = .metric
    var weight: Double = 70.0
    var height: Double = 1.70
    
    // Step 2: Training Goals
    var weeklyGoalDays: Int = 3
    var dailyCalorieBurn: Double = 500.0
    
    // Step 3: Monday Setup Tutorial
    var selectedPreset: Preset? = nil
    var showPresetPicker = false
    
    // Computed weekly calorie target
    var weeklyCalorieBurn: Double {
        Double(weeklyGoalDays) * dailyCalorieBurn
    }
    
    // Convert defaults when unit changes
    func handleUnitChange(to newSystem: UnitSystem) {
        if newSystem == .imperial {
            weight = 154.0 // 70 kg in lbs
            height = 5.6   // 1.70m in feet
        } else {
            weight = 70.0  // kg
            height = 1.70  // meters
        }
    }
    
    // MARK: - Validation
    var isMeasurementsValid: Bool {
        if unitSystem == .metric {
            return weight >= 30 && weight <= 250 && height >= 1.0 && height <= 2.5
        } else {
            return weight >= 60 && weight <= 550 && height >= 3.0 && height <= 8.2
        }
    }
    
    var isStep2Valid: Bool {
        weeklyGoalDays >= 1 && weeklyGoalDays <= 7 && dailyCalorieBurn >= 100 && dailyCalorieBurn <= 2000
    }
    
    func selectPreset(_ preset: Preset) {
        self.selectedPreset = preset
        self.showPresetPicker = false
        self.currentStep = .success
    }
    
    // MARK: - Save and Complete
    func saveAndComplete(
        profile: UserProfileModel,
        summaryManager: WorkoutSummaryManager,
        weeklySchedules: WeeklySchedules
    ) {
        // 1. Save profile values (computed setters handle metric conversion automatically)
        profile.unitSystem = unitSystem
        profile.weight = weight
        profile.height = height
        profile.weeklyGoalDays = weeklyGoalDays
        
        // 2. Save calorie goal targets
        summaryManager.dailyCalorieGoal = dailyCalorieBurn
        summaryManager.currentUserWeight = profile.weightInKilograms
        
        // 3. Save tutorial preset to Monday
        if let preset = selectedPreset {
            weeklySchedules.schedules[.monday] = preset
        }
    }
}
