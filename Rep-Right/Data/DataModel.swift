//
//  DataModel.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-16.
//

import Foundation

//MARK: - Data Types

struct Exercise: Identifiable {
    var id: UUID = UUID()
    let name: String
    var targetAreas: [String]
    var equipments: [String]
    var executionSteps: [String]
    var tips: [String]
    var assistanceAvailable: Bool
    var demoVideo: URL?
    var setData: [SetData]
}

struct SetData {
    var sets: Int
    var reps: Int
}

struct Preset: Identifiable {
    var id: UUID = UUID()
    var isRestDay: Bool = false
    let name: String
    var exercises: [Exercise]
    var isWarmpUp: Bool
    var scheduledFor: Weekday?
    var estTime: Int
    var focousArea: [String]
    var equipments: [String]
    var calories: Int
}

struct UserProfile {
    var name: String
    var age: Int
    var gender: String
    var weight: Int
    var height: Int
    var modelSensitivity: SensitivityLevels
    var unitSystem: UnitSystem
}

//MARK: - Enums

enum Weekday: String, CaseIterable{
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thrursday"
    case friday = "Friday"
    case saturday = "Saturday"
}

enum Genders: String{
    case male = "Male"
    case female = "Female"
}

enum SensitivityLevels: Int{
    case low = 0
    case medium = 1
    case high = 2
}

enum UnitSystem: String{
    case metric = "Metric"
    case imperial = "Imperial"
}

//MARK: - Dummy Data

class WeeklySchedules{
    var schedules: [Weekday: Preset] = [:]
}
 
