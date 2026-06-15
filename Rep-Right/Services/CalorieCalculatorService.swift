//
//  CalorieCalculatorService.swift
//  Rep-Right
//
//  Created by Antigravity on 13/06/26.
//

import Foundation

struct CalorieCalculatorService {
    init() {}
    
    /// Formula: Calories = MET × Weight (kg) × Time (hours)
    /// - Parameters:
    ///   - exercise: The Exercise being performed (provides .metValue from the MET dictionary)
    ///   - durationInSeconds: Exact TimeInterval captured from the active workout timer
    ///   - weightInKg: User's weight from UserProfile (defaults to 70kg if nil/unavailable)
    /// - Returns: Calories burned as a Double
    func calculateCalories(for exercise: Exercise, durationInSeconds: TimeInterval, weightInKg: Double) -> Double {
        let timeInHours = durationInSeconds / 3600.0
        return exercise.metValue * weightInKg * timeInHours
    }
}
