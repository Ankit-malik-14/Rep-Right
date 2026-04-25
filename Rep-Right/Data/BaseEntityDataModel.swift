//
//  Equipment.swift
//  Rep_Right
//
//  Created by Jugad on 25/04/26.
//


import Foundation

//MARK: - Enums

enum Equipment: String, CaseIterable, Codable, Hashable {
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case machine = "Machine"
    case bodyweight = "Bodyweight"
    case cables = "Cables"
}

enum WorkoutCategory: String, Codable, CaseIterable, Hashable {
    case strength = "Strength-Training"
    case warmup = "Warm-Up"
    case isometric = "Isometric-Training"
    
}

//MARK: - Data Types

struct ExerciseDefinition: Identifiable, Hashable{
    let id: UUID
    let name: String
    let primaryFocus: FocusArea
    //let secondaryFocus: [FocusArea]
    let equipment: [Equipment]
    let executionSteps: [String]
    let tips: [String]
    let demoVideo: URL?
    let metValue: Double
}

struct AWorkoutSet: Identifiable, Equatable, Hashable {
    let id = UUID()
    var setNumber: Int
    //var setType: SetType = .working
    var weight: Double? // Double for fractional plates (e.g., 2.5kg)
    var reps: Int?
    var durationInSec: Int? // For timed holds like Planks
    var isCompleted: Bool = false
}

struct WorkoutExercise: Identifiable, Equatable, Hashable {
    static func == (lhs: WorkoutExercise, rhs: WorkoutExercise) -> Bool {
        lhs.id == rhs.id
    }
    let id = UUID()
    let exerciseDefinition: ExerciseDefinition
    var sets: [AWorkoutSet]
}

struct PresetTemplate: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var category: WorkoutCategory
    var plannedExercises: [ExerciseDefinition]
    var scheduledFor: Weekday?
    var expectedDurationInMinutes: Int
    var FocusAreas: [FocusArea] {
        let allAreas = plannedExercises.map { $0.primaryFocus }
        let counts = allAreas.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        return counts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
    }
    var estimatedCalories: Double {
        // Implement logic based on bodyweight * MET * time
        return 0.0
    }
}

struct PresetSession: Identifiable, Equatable, Hashable {
    let id: UUID
    let templateId: UUID?
    var startTime: Date
    var endTime: Date?
    var category: WorkoutCategory
    var completedExercises: [WorkoutExercise] // Contains the actual sets, reps, and weights lifted today
}

//struct Presett: Identifiable, Equatable, Hashable {
//    let id: UUID = UUID()
//    var name: String
//    var isRestDay: Bool = false
//    var isWarmUp: Bool = false
//    var scheduledFor: Weekday?
//    var exercises: [WorkoutExercise]
//    var estTimeInMinutes: Int
//    var primaryFocusAreas: [FocusArea] {
//        let allAreas = exercises.map { $0.exerciseDefinition.primaryFocus }
//        let counts = allAreas.reduce(into: [:]) { $0[$1, default: 0] += 1 }
//        return counts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
//    }
//    // esstimated calorie calculation based on sets and durations
//    var estimatedCalories: Double {
//        //logic based on user-bodyweight * MET * time
//        return 0.0
//    }
//}

