//
//  WorkoutDetailView.swift
//  PresettFlow
//
//  Created by Jugad on 18/03/26.
//
import SwiftUI


struct Detailed: Hashable {
    var preset:Preset
}

struct WorkoutDetailView: View {
    var preset: Preset
    var executionPhase: Detailed { Detailed(preset: preset) }
    @State private var showGate = false
    @State private var showWorkout = false
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
                
                // 3. Start Workout Button
                
//                Button{
//                    
//                } label: {
//                    HStack {
//                        Image(systemName: "play.fill")
//                        Text("Start Workout")
//                    }
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(Color.orange)
//                    .cornerRadius(12)
//                }
                Button {
                    showGate = true
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
                .sheet(isPresented: $showGate) {
                    PreWorkoutGateView(preset: preset) {
                        showGate = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showWorkout = true
                        }
                    }
                }
                .navigationDestination(isPresented: $showWorkout) {
                    ActiveWorkoutView(preset: preset)
                }
                
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
//                        NavigationLink(value: Route.exercise(exercise)) {
//
//                        }
//                        .buttonStyle(.plain) // Prevents standard blue highlight
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
            
    }
}
