//
//  WorkoutDetailView.swift
//  PresettFlow
//
//  Created by Jugad on 18/03/26.
//
import SwiftUI

struct PresetDetailView: View {
    let exercises = Presets().presets[0].exercises
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // 1. Header & Stats Section (Overlapping)
                VStack(spacing: -50) {
                    PresetHeaderCardView()
                    StatsCardView()
                }
                .padding(.horizontal)
                
                // 2. Warmup Section
                    WarmUpCardView()
                        .padding(.horizontal)
                
                // 3. Start Workout Button
                Button(action: {
                    print("Start Workout Tapped")
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Workout")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // 4. Exercises List
                VStack(spacing: 16) {
                    HStack {
                        Text("Exercises")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Text("\(exercises.count) total")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(exercises) { exercise in
                        ExerciseCardView(exercise: exercise)

//                        NavigationLink(value: Route.exercise(exercise)) {
//                        }
//                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Back")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview{
        PresetDetailView()
}
