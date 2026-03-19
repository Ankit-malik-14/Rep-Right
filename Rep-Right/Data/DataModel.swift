//
//  DataModel.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-16.
//

import Foundation

//MARK: - Data Types

struct Exercise: Identifiable,Equatable,Hashable {
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }
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

struct SetData : Hashable{
    var sets: Int
    var reps: Int
}

struct Preset: Identifiable,Equatable,Hashable {
    static func == (lhs: Preset, rhs: Preset) -> Bool {
        lhs.id == rhs.id
    }
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
    var profilePicture: String?
    var name: String
    var age: Int
    var gender: Genders
    var weight: Int
    var height: Double
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

enum Genders: String, CaseIterable{
    case male = "Male"
    case female = "Female"
}

enum SensitivityLevels: Double, CaseIterable, CustomStringConvertible{
    var description: String{
        switch self {
            case .Low: return "Low"
        case .Medium: return "Medium"
        case .High: return "High"
        }
    }
    case Low = 0
    case Medium = 1
    case High = 2
}

enum UnitSystem: String, CaseIterable{
    case metric = "Metric"
    case imperial = "Imperial"
}

