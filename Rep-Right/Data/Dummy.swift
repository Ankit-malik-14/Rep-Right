//
//  Dumy.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-17.
//
import Foundation
import SwiftUI
@Observable
class Exercises{
    var exerciseList: [Exercise] = [
        Exercise(
            name: "Push-Up",
            targetAreas: ["Chest", "Triceps", "Shoulders", "Core"],
            equipments: [],
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
            image: "PushUp",
            setData: [
                SetData(sets: 3, reps: 12),
                SetData(sets: 1, reps: 10)
            ]
        ),
        Exercise(
                    name: "Wall Sit",
                    targetAreas: ["Quads", "Glutes", "Hamstrings"],
                    equipments: ["Wall"],
                    executionSteps: [
                        "Stand with your back flat against a wall.",
                        "Slide down until your knees are at 90 degrees.",
                        "Keep your back flat against the wall throughout.",
                        "Hold the position for the required time."
                    ],
                    tips: [
                        "Keep knees directly over ankles, not past toes.",
                        "Press your entire back into the wall.",
                        "Keep arms relaxed at sides or on thighs."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "WallSit",
                    setData: [SetData(sets: 3, reps: 45)]
                ),
        Exercise(
                    name: "Glute Bridge Hold",
                    targetAreas: ["Glutes", "Hamstrings", "Core"],
                    equipments: ["Mat"],
                    executionSteps: [
                        "Lie on your back with knees bent and feet flat on the floor.",
                        "Press through your heels to lift your hips toward the ceiling.",
                        "Squeeze your glutes at the top and hold.",
                        "Keep your shoulders and upper back on the mat."
                    ],
                    tips: [
                        "Don't let your lower back arch excessively.",
                        "Keep your core braced throughout.",
                        "Drive through heels, not toes."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "GluteBridge",
                    setData: [SetData(sets: 3, reps: 30)]
                ),
        Exercise(
                    name: "Dead Hang",
                    targetAreas: ["Lats", "Shoulders", "Forearms", "Core"],
                    equipments: ["Pull-up Bar"],
                    executionSteps: [
                        "Grip the bar slightly wider than shoulder-width.",
                        "Hang with arms fully extended and feet off the ground.",
                        "Keep shoulders engaged — don't let them shrug up to ears.",
                        "Hold the position with a straight body."
                    ],
                    tips: [
                        "Engage your shoulder blades by pulling them down slightly.",
                        "Breathe steadily; don't hold your breath.",
                        "Keep your core slightly braced to prevent swinging."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "DeadHang",
                    setData: [SetData(sets: 3, reps: 30)]
                ),
        Exercise(
                    name: "Overhead Hold",
                    targetAreas: ["Shoulders", "Triceps", "Core"],
                    equipments: ["Dumbbell", "Barbell"],
                    executionSteps: [
                        "Stand tall with feet shoulder-width apart.",
                        "Press weight directly overhead until arms are fully extended.",
                        "Keep wrists stacked directly above shoulders.",
                        "Brace your core and hold the position."
                    ],
                    tips: [
                        "Don't shrug your shoulders — keep them packed.",
                        "Keep ribs down; avoid flaring them.",
                        "Squeeze glutes to protect your lower back."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "OverheadHold",
                    setData: [SetData(sets: 3, reps: 30)]
                ),
        Exercise(
                    name: "Forearm Plank",
                    targetAreas: ["Core", "Shoulders", "Glutes"],
                    equipments: ["Mat"],
                    executionSteps: [
                        "Place forearms flat on the ground, elbows under shoulders.",
                        "Extend legs behind you, resting on toes.",
                        "Keep your body in a straight line from head to heels.",
                        "Hold without letting hips drop or rise."
                    ],
                    tips: [
                        "Keep elbows at exactly 90 degrees.",
                        "Press forearms into the floor to engage shoulders.",
                        "Squeeze core and glutes throughout."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                     image: "Plank",
                    setData: [SetData(sets: 3, reps: 45)]
                ),
        Exercise(
                    name: "Side Plank",
                    targetAreas: ["Obliques", "Core", "Shoulders"],
                    equipments: ["Mat"],
                    executionSteps: [
                        "Lie on your side with legs stacked and elbow under shoulder.",
                        "Lift your hips off the ground to form a straight line.",
                        "Keep your top arm extended upward or resting on your hip.",
                        "Hold without letting your hip drop toward the floor."
                    ],
                    tips: [
                        "Stack feet directly on top of each other.",
                        "Engage obliques — don't just rely on your arm.",
                        "Keep your neck neutral; don't crane it up or down."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "SidePlank",
                    setData: [SetData(sets: 3, reps: 30)]
                ),
        Exercise(
                    name: "Lunge Hold",
                    targetAreas: ["Quads", "Glutes", "Hamstrings", "Core"],
                    equipments: [],
                    executionSteps: [
                        "Step one foot forward into a lunge position.",
                        "Lower your back knee toward the floor until both knees are at 90 degrees.",
                        "Keep your torso upright and core braced.",
                        "Hold the position steadily."
                    ],
                    tips: [
                        "Front knee should stay directly above your ankle.",
                        "Don't let front knee cave inward.",
                        "Keep shoulders back and chest up."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "Lunges",
                    setData: [SetData(sets: 3, reps: 30)]
                ),
        Exercise(
                    name: "Hip Abduction Hold",
                    targetAreas: ["Glutes", "Hip Abductors", "Core"],
                    equipments: [],
                    executionSteps: [
                        "Stand tall on one leg with a slight bend in the standing knee.",
                        "Lift the opposite leg out to the side, keeping toes forward.",
                        "Raise the leg at least 20 degrees from your standing leg.",
                        "Hold the position with core engaged."
                    ],
                    tips: [
                        "Don't lean your torso to the side to compensate.",
                        "Keep your hips level — don't let one drop.",
                        "Focus your gaze on a fixed point to help balance."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "HipAbduction",
                    setData: [SetData(sets: 3, reps: 20)]
                ),
        Exercise(
                    name: "L-Sit Hold",
                    targetAreas: ["Core", "Hip Flexors", "Triceps"],
                    equipments: ["Parallel Bars", "Dip Bars"],
                    executionSteps: [
                        "Support your body on parallel bars with arms fully extended.",
                        "Lift both legs until they are parallel to the ground.",
                        "Keep legs straight and together.",
                        "Hold the position with shoulders pressed down."
                    ],
                    tips: [
                        "Push through the bars to keep shoulders depressed.",
                        "Point toes to help engage legs fully.",
                        "Tighten your core as hard as possible."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "LSitHold",
                    setData: [SetData(sets: 3, reps: 15)]
                ),
        Exercise(
                    name: "Hollow Body Hold",
                    targetAreas: ["Core", "Hip Flexors", "Shoulders"],
                    equipments: ["Mat"],
                    executionSteps: [
                        "Lie on your back and press your lower back firmly into the mat.",
                        "Raise your arms overhead and lift your legs to about 30 degrees.",
                        "Lift your shoulders slightly off the mat.",
                        "Hold the banana-shaped body position."
                    ],
                    tips: [
                        "The lower back must stay pressed into the mat at all times.",
                        "The lower the legs, the harder it gets — adjust as needed.",
                        "If too hard, bend your knees to reduce the lever arm."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "HollowBodyHold",
                    setData: [SetData(sets: 3, reps: 20)]
                ),
        Exercise(
                    name: "Superman Hold",
                    targetAreas: ["Lower Back", "Glutes", "Hamstrings", "Shoulders"],
                    equipments: ["Mat"],
                    executionSteps: [
                        "Lie face down with arms extended overhead and legs straight.",
                        "Simultaneously lift your arms, chest, and legs off the ground.",
                        "Squeeze your glutes and lower back to hold the position.",
                        "Keep your neck neutral — don't crane it upward."
                    ],
                    tips: [
                        "Lift arms and legs at the same time for balance.",
                        "Don't hold your breath — breathe steadily.",
                        "Focus on squeezing glutes, not just arching the back."
                    ],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    setData: [SetData(sets: 3, reps: 20)]
                ),
        Exercise(
            name: "Bodyweight Squat",
            targetAreas: ["Quads", "Glutes", "Hamstrings", "Core"],
            equipments: [],
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
            image: "Squats",
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
            image: "DumbellRow",
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
            image: "Plank",
            setData: [
                SetData(sets: 3, reps: 45) // interpret reps as seconds for isometric holds
            ]
        ),
        Exercise(
                    name: "Bench Press",
                    targetAreas: ["Chest", "Triceps", "Shoulders"],
                    equipments: ["Barbell", "Bench"],
                    executionSteps: ["Lie on the bench.", "Lower bar to chest.", "Press up."],
                    tips: ["Keep feet planted."],
                    assistanceAvailable: false,
                    demoVideo: nil,
                    image: "BenchPress",
                    setData: [SetData(sets: 3, reps: 10)]
                ),
                Exercise(
                    name: "Bicep Curl",
                    targetAreas: ["Biceps"],
                    equipments: ["Dumbbell"],
                    executionSteps: ["Curl weight towards shoulders.", "Control the lowering."],
                    tips: ["Keep elbows tucked."],
                    assistanceAvailable: false,
                    demoVideo: nil,
                    image: "BicepCurl",
                    setData: [SetData(sets: 3, reps: 12)]
                ),
                Exercise(
                    name: "Crunches",
                    targetAreas: ["Core"],
                    equipments: ["Mat"],
                    executionSteps: ["Lie back, lift shoulders off floor."],
                    tips: ["Do not pull on neck."],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "Crunches",
                    setData: [SetData(sets: 3, reps: 20)]
                ),
                Exercise(
                    name: "Dumbbell Press",
                    targetAreas: ["Chest", "Shoulders"],
                    equipments: ["Dumbbell", "Bench"],
                    executionSteps: ["Press dumbbells up from shoulder level."],
                    tips: ["Control descent."],
                    assistanceAvailable: false,
                    demoVideo: nil,
                    image: "DumbbellPress",
                    setData: [SetData(sets: 3, reps: 10)]
                ),
                Exercise(
                    name: "Jumping Jacks",
                    targetAreas: ["Cardio", "Full Body"],
                    equipments: [],
                    executionSteps: ["Jump feet out, hands over head."],
                    tips: ["Maintain rhythm."],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "JumpingJacks",
                    setData: [SetData(sets: 3, reps: 50)]
                ),
                Exercise(
                    name: "Lat Pulldown",
                    targetAreas: ["Lats"],
                    equipments: ["Cable Machine"],
                    executionSteps: ["Pull bar to upper chest."],
                    tips: ["Engage lats, not just arms."],
                    assistanceAvailable: false,
                    demoVideo: nil,
                    image: "LatPullDown",
                    setData: [SetData(sets: 3, reps: 12)]
                ),
                Exercise(
                    name: "Leg Raise",
                    targetAreas: ["Core", "Hip Flexors"],
                    equipments: ["Mat"],
                    executionSteps: ["Lift legs while lying flat."],
                    tips: ["Keep lower back pressed down."],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "LegRaise",
                    setData: [SetData(sets: 3, reps: 15)]
                ),
                Exercise(
                    name: "Shoulder Stretch",
                    targetAreas: ["Shoulders"],
                    equipments: [],
                    executionSteps: ["Pull arm across chest."],
                    tips: ["Keep shoulder down."],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "ShoulderStrech",
                    setData: [SetData(sets: 1, reps: 30)] // seconds
                ),
                Exercise(
                    name: "Side Stretch",
                    targetAreas: ["Obliques"],
                    equipments: [],
                    executionSteps: ["Reach arm overhead to side."],
                    tips: ["Keep hips square."],
                    assistanceAvailable: true,
                    demoVideo: nil,
                    image: "SideStretch",
                    setData: [SetData(sets: 1, reps: 30)] // seconds
                )
    ]
}

@Observable
class Presets {
    var presets: [Preset] = [
        Preset(
            name: "Full Body",
            image: "FullBody",
            exercises: Exercises().exerciseList,
            isWarmpUp: false,
            scheduledFor: .monday,
            estTime: 45,
            equipments: ["Bodyweight", "Dumbbell", "Bench"],
            calories: 450
        ),
        Preset(
            name: "Upper Focus",
            image: "Shoulders",
            exercises: Exercises().exerciseList,
            isWarmpUp: false,
            scheduledFor: .wednesday,
            estTime: 35,
            equipments: ["Bodyweight", "Dumbbell", "Bench"],
            calories: 380
        ),
        Preset(
            name: "Core & Stability",
            image: "Core",
            exercises: Exercises().exerciseList,
            isWarmpUp: false,
            scheduledFor: .friday,
            estTime: 30,
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
            equipments: [],
            calories: 120
        ),
        Preset(
            name: "Lower Body Builder",
            image: "Legs",
            exercises: Exercises().exerciseList,
            isWarmpUp: false,
            scheduledFor: .thursday,
            estTime: 40,
            equipments: ["Bodyweight", "Mat"],
            calories: 420
        )
    ]
}

@Observable
class CustomPresetsDummyData{
    var customPresets: [Preset] = []/*[
        Preset(
            name: "Full body ",
            exercises: Array(Exercises().exerciseList.prefix(3)),
            isWarmpUp: false,
            scheduledFor: .tuesday,
            estTime: 25,
            equipments: ["Bodyweight"],
            calories: 260
        ),
        Preset(
            name: "Push + Core",
            image: "Core",
            exercises: Exercises().exerciseList.filter { ["Push-Up", "Plank"].contains($0.name) },
            isWarmpUp: false,
            scheduledFor: .thursday,
            estTime: 20,
            equipments: ["Bodyweight", "Mat"],
            calories: 220
        ),
        Preset(
            name: "Back Focus",
            exercises: Exercises().exerciseList.filter { ["Dumbbell Row", "Plank"].contains($0.name) },
            isWarmpUp: false,
            scheduledFor: .saturday,
            estTime: 25,
            equipments: ["Dumbbell", "Bench", "Mat"],
            calories: 250
        ),
        Preset(
            isRestDay: true,
            name: "Recovery + Mobility",
            exercises: [],
            isWarmpUp: true,
            scheduledFor: .sunday,
            estTime: 15,
            equipments: ["Mat"],
            calories: 100
        )
    ]*/
    func add(_ preset: Preset){
        customPresets.append(preset)
    }
    func delete(_ preset: Preset){
        customPresets.removeAll{$0.id == preset.id}
    }
    func delete(atOffsets offsets: IndexSet) {
        customPresets.remove(atOffsets: offsets)
    }
}

/* DEPRECATED: Replaced by the global @Observable UserProfileModel injected via environment.
class DummyUserProfiles {
    var user = UserProfile(profilePicture: "UserImage", name: "Ankit Malik", age: 21, gender: .male , weight: 71, height: 1.73, modelSensitivity: .Medium, unitSystem: .metric)
}
*/
@Observable
class WeeklySchedules{
    var schedules: [Weekday: Preset] = [.wednesday:Preset(
        name: "Full Body Starter",
        exercises: Exercises().exerciseList,
        isWarmpUp: false,
        scheduledFor: .monday,
        estTime: 45,
        /*focousArea: ["Full Body"],*/
        equipments: ["Bodyweight", "Dumbbell", "Bench"],
        calories: 450
    )]
}

