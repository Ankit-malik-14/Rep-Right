//
//  ExerciseCatalog.swift
//  Rep_Right
//
//  Created by Jugad on 25/04/26.
//

import Foundation

// MARK: - 1.Exercise Catalog
@Observable
class ExerciseCatalog {
    static let shared = ExerciseCatalog()
    
    let definitions: [ExerciseDefinition] = [
        ExerciseDefinition(
            id:  UUID(),
            name: "Push-Up",
            primaryFocus: .chest,
            equipment: [.bodyweight],
            executionSteps: [
                "Start in a high plank with hands slightly wider than shoulder-width.",
                "Brace your core and keep a straight line from head to heels.",
                "Lower your chest toward the floor by bending your elbows.",
                "Press through your palms to return to the starting position."
            ],
            tips: [
                "Keep elbows at ~45° from your torso.",
                "Do not let hips sag; maintain a neutral spine."
            ],
            demoVideo: URL(string: "https://example.com/videos/pushup.mp4"),
            metValue: 3.8
        ),
        ExerciseDefinition(
            id:  UUID(),
            name: "Bodyweight Squat",
            primaryFocus: .legs,
            equipment: [.bodyweight],
            executionSteps: [
                "Stand with feet shoulder-width apart and toes slightly out.",
                "Sit your hips back and down while keeping your chest up.",
                "Lower until thighs are at least parallel to the floor.",
                "Drive through mid-foot to return to standing."
            ],
            tips: ["Keep knees tracking over toes.", "Maintain a neutral spine."],
            demoVideo: URL(string: "https://example.com/videos/bodyweight_squat.mp4"),
            metValue: 5.0
        ),
        ExerciseDefinition(
            id:  UUID(),
            name: "Dumbbell Row",
            primaryFocus: .back,
            equipment: [.dumbbell, .bodyweight], 
            executionSteps: [
                "Place one knee and hand on a bench for support.",
                "Row the dumbbell toward your hip, squeezing your back.",
                "Lower the weight under control."
            ],
            tips: ["Keep your torso still; avoid twisting.", "Lead with the elbow."],
            demoVideo: URL(string: "https://example.com/videos/dumbbell_row.mp4"),
            metValue: 4.5
        ),
        ExerciseDefinition(
            id:  UUID(),
            name: "Plank",
            primaryFocus: .core,
            equipment: [.bodyweight],
            executionSteps: [
                "Start on forearms and toes with body in a straight line.",
                "Engage core and glutes; keep neck neutral.",
                "Hold position without letting hips drop."
            ],
            tips: ["Think about pulling your ribs toward your pelvis.", "Breathe steadily."],
            demoVideo: URL(string: "https://example.com/videos/plank.mp4"),
            metValue: 3.0
        )
    ]
}

// MARK: - 2. Preset Templates (The Plans)
@Observable
class WorkoutTemplates {
    static let shared = WorkoutTemplates()
    var templates: [PresetTemplate] = []
    init() {
        let catalog = ExerciseCatalog.shared.definitions
        
        self.templates = [
            PresetTemplate(
                id: UUID(),
                name: "Full Body Starter",
                category: .strength,
                plannedExercises: [
                    catalog.first(where: { $0.name == "Push-Up" })!,
                    catalog.first(where: { $0.name == "Bodyweight Squat" })!,
                    catalog.first(where: { $0.name == "Dumbbell Row" })!
                ],
                scheduledFor: .monday,
                expectedDurationInMinutes: 45
            ),
            PresetTemplate(
                id: UUID(),
                name: "Upper Focus",
                category: .strength,
                plannedExercises: [
                    catalog.first(where: { $0.name == "Push-Up" })!,
                    catalog.first(where: { $0.name == "Dumbbell Row" })!
                ],
                scheduledFor: .wednesday,
                expectedDurationInMinutes: 35
            ),
            PresetTemplate(
                id: UUID(),
                name: "Core Activation",
                category: .isometric,
                plannedExercises: [
                    catalog.first(where: { $0.name == "Plank" })!
                ],
                scheduledFor: .friday,
                expectedDurationInMinutes: 15
            ),
            PresetTemplate(
                id: UUID(),
                name: "Active Recovery",
                category: .warmup,
                plannedExercises: [],
                scheduledFor: .sunday,
                expectedDurationInMinutes: 20
            )
        ]
    }
}

// MARK: - 3. Workout Sessions (The History / Actual Logs)
@Observable
class WorkoutHistory {
    static let shared = WorkoutHistory()
    var pastSessions: [PresetSession] = []
    init() {
        let catalog = ExerciseCatalog.shared.definitions
        let templates = WorkoutTemplates.shared.templates
        
        self.pastSessions = [
            PresetSession(
                id: UUID(),
                templateId: templates.first(where: { $0.name == "Full Body Starter" })?.id,
                startTime: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                endTime: Calendar.current.date(byAdding: .minute, value: 42, to: Calendar.current.date(byAdding: .day, value: -2, to: Date())!)!,
                category: .strength,
                completedExercises: [
                    WorkoutExercise(
                        exerciseDefinition: catalog.first(where: { $0.name == "Push-Up" })!,
                        sets: [
                            AWorkoutSet(setNumber: 1, weight: nil, reps: 15, durationInSec: nil, isCompleted: true),
                            AWorkoutSet(setNumber: 2, weight: nil, reps: 12, durationInSec: nil, isCompleted: true),
                            AWorkoutSet(setNumber: 3, weight: nil, reps: 10, durationInSec: nil, isCompleted: true)
                        ]
                    ),
                    WorkoutExercise(
                        exerciseDefinition: catalog.first(where: { $0.name == "Dumbbell Row" })!,
                        sets: [
                            AWorkoutSet(setNumber: 1, weight: 15.0, reps: 10, durationInSec: nil, isCompleted: true),
                            AWorkoutSet(setNumber: 2, weight: 17.5, reps: 8, durationInSec: nil, isCompleted: true),
                            AWorkoutSet(setNumber: 3, weight: 17.5, reps: 8, durationInSec: nil, isCompleted: true)
                        ]
                    )
                ]
            ),
            
            PresetSession(
                id: UUID(),
                templateId: nil,
                startTime: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                endTime: Calendar.current.date(byAdding: .minute, value: 5, to: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)!,
                category: .isometric,
                completedExercises: [
                    WorkoutExercise(
                        exerciseDefinition: catalog.first(where: { $0.name == "Plank" })!,
                        sets: [
                            AWorkoutSet(setNumber: 1, weight: nil, reps: nil, durationInSec: 60, isCompleted: true)
                        ]
                    )
                ]
            )
        ]
    }
}
