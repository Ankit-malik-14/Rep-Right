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

var excercises: [Exercise] = [
    Exercise(
        name: "Push-Up",
        targetAreas: ["Chest", "Triceps", "Shoulders", "Core"],
        equipments: ["Bodyweight"],
        executionSteps: [
            "Start in a high plank with hands slightly wider than shoulder-width.",
            "Brace your core and keep a straight line from head to heels.",
            "Lower your chest toward the floor by bending your elbows.",
            "Press through your palms to return to the starting position."
        ],
        tips: [
            "Keep elbows at ~45° from your torso.",
            "Do not let hips sag; maintain a neutral spine.",
            "Inhale on the way down, exhale as you press up."
        ],
        assistanceAvailable: true,
        demoVideo: URL(string: "https://example.com/videos/pushup.mp4"),
        setData: [
            SetData(sets: 3, reps: 12),
            SetData(sets: 1, reps: 10)
        ]
    ),
    Exercise(
        name: "Bodyweight Squat",
        targetAreas: ["Quads", "Glutes", "Hamstrings", "Core"],
        equipments: ["Bodyweight"],
        executionSteps: [
            "Stand with feet shoulder-width apart and toes slightly out.",
            "Sit your hips back and down while keeping your chest up.",
            "Lower until thighs are at least parallel to the floor.",
            "Drive through mid-foot to return to standing."
        ],
        tips: [
            "Keep knees tracking over toes.",
            "Maintain a neutral spine; avoid rounding your back.",
            "Control the descent; don’t bounce at the bottom."
        ],
        assistanceAvailable: false,
        demoVideo: URL(string: "https://example.com/videos/bodyweight_squat.mp4"),
        setData: [
            SetData(sets: 4, reps: 15)
        ]
    ),
    Exercise(
        name: "Dumbbell Row",
        targetAreas: ["Lats", "Rhomboids", "Biceps", "Rear Delts"],
        equipments: ["Dumbbell", "Bench"],
        executionSteps: [
            "Place one knee and hand on a bench for support, other foot on the floor.",
            "Hold a dumbbell with the free hand, arm extended toward the floor.",
            "Row the dumbbell toward your hip, squeezing your back.",
            "Lower the weight under control to the start position."
        ],
        tips: [
            "Keep your torso still; avoid twisting.",
            "Lead with the elbow and keep the wrist neutral.",
            "Exhale as you row, inhale as you lower."
        ],
        assistanceAvailable: false,
        demoVideo: URL(string: "https://example.com/videos/dumbbell_row.mp4"),
        setData: [
            SetData(sets: 3, reps: 10)
        ]
    ),
    Exercise(
        name: "Plank",
        targetAreas: ["Core", "Shoulders", "Glutes"],
        equipments: ["Mat"],
        executionSteps: [
            "Start on forearms and toes with body in a straight line.",
            "Engage core and glutes; keep neck neutral.",
            "Hold position without letting hips drop or pike."
        ],
        tips: [
            "Think about pulling your ribs toward your pelvis.",
            "Breathe steadily; don’t hold your breath.",
            "Squeeze glutes lightly to stabilize pelvis."
        ],
        assistanceAvailable: true,
        demoVideo: URL(string: "https://example.com/videos/plank.mp4"),
        setData: [
            SetData(sets: 3, reps: 45) // interpret reps as seconds for isometric holds
        ]
    )
]

@Observable
class Presets {
    var presets: [Preset] = [
        Preset(
            name: "Full Body Starter",
            exercises: excercises,
            isWarmpUp: false,
            scheduledFor: .monday,
            estTime: 45,
            focousArea: ["Full Body"],
            equipments: ["Bodyweight", "Dumbbell", "Bench"],
            calories: 450
        ),
        Preset(
            name: "Upper Focus",
            exercises: [excercises[0], excercises[2]],
            isWarmpUp: false,
            scheduledFor: .wednesday,
            estTime: 35,
            focousArea: ["Chest", "Back", "Arms"],
            equipments: ["Bodyweight", "Dumbbell", "Bench"],
            calories: 380
        ),
        Preset(
            name: "Core & Stability",
            exercises: [excercises[3], excercises[0]],
            isWarmpUp: false,
            scheduledFor: .friday,
            estTime: 30,
            focousArea: ["Core", "Shoulders"],
            equipments: ["Mat", "Bodyweight"],
            calories: 300
        ),
        Preset(
            isRestDay: true,
            name: "Active Recovery",
            exercises: [],
            isWarmpUp: true,
            scheduledFor: .sunday,
            estTime: 20,
            focousArea: ["Mobility", "Recovery"],
            equipments: [],
            calories: 120
        ),
        Preset(
            name: "Lower Body Builder",
            exercises: [excercises[1], excercises[3]],
            isWarmpUp: false,
            scheduledFor: .thursday,
            estTime: 40,
            focousArea: ["Legs", "Glutes"],
            equipments: ["Bodyweight", "Mat"],
            calories: 420
        )
    ]
}

class WeeklySchedules{
    var schedules: [Weekday: Preset] = [:]
}
 
