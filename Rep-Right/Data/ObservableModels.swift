//
//  ObservableModels.swift
//  Rep-Right
//

import Foundation
import Observation

// MARK: - Calorie Entry (Charts data point)

struct CalorieEntry: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

// MARK: - User Profile Model (MVVM @Observable)
/* DEPRECATED: Moved to DataModel.swift to centralize profile logic.
@Observable
class UserProfileModel {
    var name: String = "Ankit Malik"
    var weight: Double = 71.0
}
*/

// MARK: - Summary Data Model (MVVM @Observable)
/* DEPRECATED: Redundant model. The app now natively calculates all metrics using WorkoutSummaryManager.
@Observable
class SummaryData {
    var weeklyCalories: [CalorieEntry] = [
        .init(day: "Mon", value: 320), .init(day: "Tue", value: 480),
        .init(day: "Wed", value: 150), .init(day: "Thu", value: 520),
        .init(day: "Fri", value: 390), .init(day: "Sat", value: 610),
        .init(day: "Sun", value: 200)
    ]
    var calorieTarget: Double = 500
    var progress: Double = 0.72
    var activeMinutes: Int = 185
    var targetMinutes: Int = 250
}
*/

// MARK: - Summary Navigation Routes
// MOVED to AppRoutes/EnumRoutes.swift
