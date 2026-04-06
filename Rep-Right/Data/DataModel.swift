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
    // var expectedTimeInSec: Int  //with this and met value we can show expected calorie burn for let's say 5mins for example.
    // var mETValue: Double
}

struct SetData : Hashable{
    var sets: Int
    var reps: Int
    //needs optional weight, var wieght: Int?
    //needs duration for timed exercises, var durationInSec: Int?
}

struct Preset: Identifiable, Equatable, Hashable {
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
    //now focus area can become enum and we can process with CaseIterable's .allTypes
    var focousArea: [String] {
        // Compute the top 3 most frequent target areas across all exercises in this preset
        let allAreas = exercises.flatMap { $0.targetAreas }
        guard !allAreas.isEmpty else { return [] }
        var counts: [String: Int] = [:]
        for area in allAreas {
            counts[area, default: 0] += 1
        }
        let sorted = counts.sorted {
            if $0.value == $1.value {
                return $0.key < $1.key
            }
            return $0.value > $1.value
        }
        return Array(sorted.prefix(3).map { $0.key })
    }
    var equipments: [String]
    var calories: Int
    // var calories: Int {exercises.reduce(0){$0 + ($1.metValue * $1.expectedTimeInSec)}} //computed property
}

struct UserProfile:Hashable {
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

enum Weekday: Int, CaseIterable{
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

enum Genders: String, CaseIterable,Hashable{
    case male = "Male"
    case female = "Female"
}

enum SensitivityLevels: Double, CaseIterable, CustomStringConvertible,Hashable{
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

enum UnitSystem: String, CaseIterable,Hashable{
    case metric = "Metric"
    case imperial = "Imperial"
}

/*enum targetMuscleGroup: String, CaseIterable {
    case shoulder = "Shoulder"
    case chest = "Chest"
    case back = "Back"
    case legs = "Legs"
    case core = "Core"
    case arms = "Arms"
}
*/
