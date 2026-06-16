//
//  ExercisesView.swift
//  Rep-Right
//
//  Created by GU on 17/03/26.
//

import SwiftUI

struct ExercisesView: View {
    var exercise: Exercise
    @Environment(UserProfileModel.self) private var userProfile
    @AppStorage private var hasSeenExerciseGuide: Bool
    
    @State private var isExecutionExpanded: Bool = true
    @State private var showTooltip = false
    
    /// Bridge: wraps this single exercise into a Preset so ActiveWorkoutView can consume it.
    private var singleExercisePreset: Preset { Preset.from(singleExercise: exercise) }
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self._hasSeenExerciseGuide = AppStorage(wrappedValue: false, "hasSeenExerciseGuide_\(exercise.id)")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .topLeading){
                        if exercise.assistanceAvailable {
                            assisstanceAvailablityTag(type: .iconAndText)
                                .padding()
                                .offset(x:13)
                                .overlay(alignment: .bottomLeading) {
                                    if showTooltip {
                                        Text("Tap 'Try Workout' then enable camera for real-time form feedback.")
                                            .font(.caption)
                                            .padding(10)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .shadow(radius: 4)
                                            .offset(x: 13, y: 50)
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                            .zIndex(1)
                                    }
                                }
                        }
                        
                        ZStack{
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 100,height: 100)
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.gray.opacity(0.15))
                                .frame(height: 300)
                                .padding(.horizontal)
                        }
                    }
                    HStack {
                        Text(exercise.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        
                        HStack(alignment: .top) {
                            Text("Muscle Group:")
                                .font(.footnote)
                                .fontWeight(.bold)
                            
                            Text(exercise.primaryFocusArea?.rawValue ?? arrayToString(arrayOfStrings: exercise.targetAreas))
                                .font(.footnote)
                        }
                        .padding(.bottom,5)
                        
                        HStack {
                            Text("Equipment :")
                                .font(.footnote)
                                .fontWeight(.bold)
                            
                            Text(arrayToString(arrayOfStrings: exercise.equipments))
                                .font(.footnote)
                        }.padding(.bottom,5)
                        
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    DisclosureGroup(isExpanded: $isExecutionExpanded) {
                        VStack(alignment: .leading, spacing: 10) {
                            pointView(steps: exercise.executionSteps)
                                .padding(.top, 10)
                        }
                    } label: {
                        Text("Execution")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    
                    Text("Tips")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        pointView(steps: exercise.tips)
                            .padding(.horizontal)
                        }
                    .padding(.horizontal)
                        
                    
                    HStack(spacing: 12) {
                        NavigationLink(value: WorkoutRoute.activeWorkout(singleExercisePreset)) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Try Workout")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.orange)
                            .foregroundStyle(.white)
                            .cornerRadius(25)
                        }
                    }.padding()
                }
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            isExecutionExpanded = (userProfile.fitnessLevel == .beginner)
            
            if userProfile.fitnessLevel == .beginner && !hasSeenExerciseGuide {
                withAnimation {
                    showTooltip = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        showTooltip = false
                    }
                    hasSeenExerciseGuide = true
                }
            }
        }
    }
}
#Preview {
    @Previewable var exercise = Exercise(
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
        setData: [
            SetData(sets: 3, reps: 12),
            SetData(sets: 1, reps: 10)
        ]
    )
    ExercisesView(exercise: exercise)
}




   
