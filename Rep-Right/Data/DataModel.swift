//
//  DataModel.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-16.
//
import Foundation

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
    var image: String?
    var setData: [SetData]
    var primaryFocusArea: FocusArea? {
        guard let firstTarget = targetAreas.first else { return nil }
        return FocusArea.from(targetArea: firstTarget)
    }
    
    // MARK: - MET Value Lookup
    // Scientifically accurate MET values mapped by exercise name.
    // Source: Compendium of Physical Activities (Ainsworth et al.)
    // Fallback: 3.5 (moderate-effort general exercise)
    
    private static let metDictionary: [String: Double] = [
        // Compound lower body
        "Bodyweight Squat":     5.0,
        "Barbell Squat":        6.0,
        "Goblet Squat":         5.5,
        "Lunges":               4.0,
        "Bulgarian Split Squat": 5.0,
        "Deadlift":             6.0,
        "Romanian Deadlift":    5.5,
        "Hip Thrust":           4.5,
        "Leg Press":            5.0,
        "Leg Curl":             3.5,
        "Leg Extension":        3.5,
        "Calf Raise":           3.0,
        
        // Compound upper body
        "Push-Up":              3.8,
        "Bench Press":          5.0,
        "Incline Bench Press":  5.0,
        "Dumbbell Press":       5.0,
        "Overhead Press":       5.0,
        "Dumbbell Row":         4.5,
        "Barbell Row":          5.0,
        "Pull-Up":              8.0,
        "Chin-Up":              7.5,
        "Lat Pulldown":         4.5,
        "Dip":                  5.0,
        
        // Isolation
        "Bicep Curl":           3.5,
        "Tricep Extension":     3.0,
        "Lateral Raise":        3.0,
        "Face Pull":            3.0,
        "Fly":                  3.5,
        
        // Core & isometric
        "Plank":                3.0,
        "Sit-Up":               3.8,
        "Crunch":               3.0,
        "Russian Twist":        3.5,
        "Hanging Leg Raise":    4.0,
        "Mountain Climber":     8.0,
        
        // Cardio / conditioning
        "Burpee":               8.0,
        "Jumping Jack":         7.0,
        "Jump Rope":            10.0,
        "Box Jump":             8.0,
        "Dynamic Warm-up":      3.5,
        "Battle Ropes":         10.0,
        "Rowing":               7.0,
        
    ]
    
    /// Returns the MET value for this exercise.
    /// Falls back to 3.5 (moderate general exercise) if the name isn't in the dictionary.
    var metValue: Double {
        Exercise.metDictionary[name] ?? 3.5
    }
}

struct SetData : Hashable{
    var sets: Int
    var reps: Int
    //needs optional weight, var wieght: Int?
    //needs duration for timed exercises, var durationInSec: Int?
}

enum FocusArea: String, CaseIterable, Hashable {
    case shoulder = "Shoulder"
    case back = "Back"
    case chest = "Chest"
    case arms = "Arms"
    case core = "Core"
    case legs = "Legs"

    static func from(targetArea: String) -> FocusArea? {
        let normalized = targetArea
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch normalized {
        case "shoulder", "shoulders", "delts", "delt", "rear delts", "front delts", "side delts":
            return .shoulder
        case "back", "lats", "rhomboids", "traps":
            return .back
        case "chest", "pecs", "pectorals":
            return .chest
        case "arm", "arms", "biceps", "triceps", "forearms":
            return .arms
        case "core", "abs", "abdominals", "obliques":
            return .core
        case "leg", "legs", "quads", "glutes", "hamstrings", "calves":
            return .legs
        default:
            if normalized.contains("delt") || normalized.contains("shoulder") {
                return .shoulder
            }
            if normalized.contains("lat") || normalized.contains("rhomboid") || normalized.contains("trap") || normalized.contains("back") {
                return .back
            }
            if normalized.contains("chest") || normalized.contains("pec") {
                return .chest
            }
            if normalized.contains("bicep") || normalized.contains("tricep") || normalized.contains("forearm") || normalized.contains("arm") {
                return .arms
            }
            if normalized.contains("core") || normalized.contains("ab") || normalized.contains("oblique") {
                return .core
            }
            if normalized.contains("quad") || normalized.contains("glute") || normalized.contains("hamstring") || normalized.contains("calf") || normalized.contains("leg") {
                return .legs
            }
            return nil
        }
    }
}

// Used by ActiveWorkoutView
struct WorkoutSet: Identifiable {
    let id = UUID()
    var setNumber: Int
    var weight: String
    var reps: String
    var isCompleted: Bool = false
}

struct Preset: Identifiable, Equatable, Hashable {
    static func == (lhs: Preset, rhs: Preset) -> Bool {
        lhs.id == rhs.id
    }
    var id: UUID = UUID()
    var isRestDay: Bool = false
    let name: String
    var image: String?
    var exercises: [Exercise]
    var isWarmpUp: Bool
    var scheduledFor: Weekday?
    var estTime: Int
    //now focus area can become enum and we can process with CaseIterable's .allTypes
    var focousArea: [String] {
        // Compute the top 3 most frequent primary focus areas across all exercises in this preset
        let allAreas = exercises.compactMap { $0.primaryFocusArea?.rawValue }
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

extension Preset {
    /// Helper to run a single exercise inside the standardized ActiveWorkoutView pipeline.
    static func from(singleExercise exercise: Exercise) -> Preset {
        return Preset(
            id: UUID(),
            isRestDay: false,
            name: exercise.name,
            exercises: [exercise],
            isWarmpUp: false,
            scheduledFor: nil,
            estTime: 5, // Rough estimate
            equipments: exercise.equipments,
            calories: Int(exercise.metValue * 5.0) // Rough generic calculation
        )
    }
}

enum FitnessLevel: String, CaseIterable, Hashable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

// UPDATED: Consolidated UserProfile struct into an @Observable class to act as the single source of truth.
@Observable
class UserProfileModel {
    var profilePicture: String? = "UserImage"
    var name: String = "Ankit Malik"
    var age: Int = 21
    var gender: Genders = .male
    var modelSensitivity: SensitivityLevels = .Medium
    var fitnessLevel: FitnessLevel = .beginner
    var weeklyGoalDays: Int = 3
    
    var unitSystem: UnitSystem = .metric
    
    // MARK: - Single Source of Truth (Always Metric)
    // We keep these private so the rest of the app doesn't accidentally bypass the conversion logic.
    private var storedWeightKg: Double = 71.0
    private var storedHeightMeters: Double = 1.73
    
    // MARK: - Computed Bindings for UI
    
    /// Returns weight in kg or lbs based on the current `unitSystem`.
    /// When the user types into the TextField, the `set` block automatically converts it back to kg for safe storage.
    /// Returns weight in kg or lbs based on the current `unitSystem`.
        var weight: Double {
            get {
                switch unitSystem {
                case .metric:
                    return (storedWeightKg * 10).rounded() / 10.0
                case .imperial:
                    let lbs = storedWeightKg * 2.20462
                    return (lbs * 10).rounded() / 10.0 // Rounds to 1 decimal place
                }
            }
            set {
                switch unitSystem {
                case .metric:
                    storedWeightKg = newValue
                case .imperial:
                    storedWeightKg = newValue / 2.20462 // Convert lbs back to kg
                }
            }
        }
        
        /// Returns height in meters or feet based on the current `unitSystem`.
        var height: Double {
            get {
                switch unitSystem {
                case .metric:
                    return (storedHeightMeters * 100).rounded() / 100.0 // 2 decimal places for meters (e.g., 1.73)
                case .imperial:
                    let feet = storedHeightMeters * 3.28084
                    return (feet * 10).rounded() / 10.0 // 1 decimal place for feet
                }
            }
            set {
                switch unitSystem {
                case .metric:
                    storedHeightMeters = newValue
                case .imperial:
                    storedHeightMeters = newValue / 3.28084 // Convert feet back to meters
                }
            }
        }
}
/*class UserProfileModel {
    var profilePicture: String? = "UserImage"
    var name: String = "Ankit Malik"
    var age: Int = 21
    var gender: Genders = .male
    var weight: Double = 71.0
    var height: Double = 1.73
    var modelSensitivity: SensitivityLevels = .Medium
    var unitSystem: UnitSystem = .metric
    var fitnessLevel: FitnessLevel = .beginner
    var weeklyGoalDays: Int = 3
}*/

/* DEPRECATED: Replaced by @Observable class UserProfileModel. Logic moved to unified model for MVVM.
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

private struct UserProfileKey: EnvironmentKey {
    static let defaultValue: UserProfile? = nil
}

extension EnvironmentValues {
    var userProfile: UserProfile? {
        get { self[UserProfileKey.self] }
        set { self[UserProfileKey.self] = newValue }
    }
}
*/

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
