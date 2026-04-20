//
//  ExercisesView.swift
//  Rep-Right
//
//  Created by GU on 17/03/26.
//

import SwiftUI

struct ExercisesView: View {
    var exercise: Exercise
    @State private var showWorkout = false
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .topLeading){
                        if exercise.assistanceAvailable {
                            assisstanceAvailablityTag(type: .iconAndText).padding().offset(x:13)
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
                            Text("Focus Area :")
                                .font(.footnote)
                                .fontWeight(.bold)
                            
                            Text(arrayToString(arrayOfStrings: exercise.targetAreas))
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
                    
                    Text("Execution")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        pointView(steps: exercise.executionSteps)
                    .padding(.horizontal)
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
                        
                        /*Button(action: {
                            
                        }) {
                            Text("Done")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(25)
                        }
                        */
                        Button(action: {
                            showWorkout = true
                        }) {
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
        .fullScreenCover(isPresented: $showWorkout) {
            IndividualRunningExerciseView(exercise: exercise)
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




   
