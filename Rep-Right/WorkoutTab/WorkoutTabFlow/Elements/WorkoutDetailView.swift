//
//  WorkoutDetailView.swift
//  PresettFlow
//
//  Created by Jugad on 18/03/26.
//
import SwiftUI

struct WorkoutDetailView: View {
    var preset: Preset
    @Environment(WorkoutRouter.self) private var router

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // 1. Header & Stats Section (Overlapping)
                VStack(spacing: -50) {
                    PresetHeaderCardView()
                    StatsCardView(preset: preset)
                }
                .padding(.horizontal)
                
                // 2. Warmup Section (value-based, type-safe)
                WarmUpCardView()
                    .padding(.horizontal)
                
                // 3. Start Workout Button — pushes PreWorkoutGate via router
                Button {
                    router.push(.preWorkoutGate(preset))
                } label: {
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
                        Text("\(preset.exercises.count) total")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(preset.exercises) { exercise in
                        ExerciseCardView(exercise: exercise)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle(preset.name)
            .padding(.bottom, 40)
        }
        
        .navigationTitle(preset.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    
    NavigationStack{
        WorkoutDetailView(preset: Presets().presets[0])
            .environment(WeeklySchedules())
            .environment(WorkoutRouter())
            
    }
}
