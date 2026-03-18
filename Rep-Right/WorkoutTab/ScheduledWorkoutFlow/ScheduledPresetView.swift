//
//  ScheduledPresetView.swift
//  PresettFlow
//
//  Created by Jugad on 17/03/26.
//

import SwiftUI


// MARK: - Content View (Entry Point)
struct ScheduledPresetView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Home Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                // Modern NavigationLink using a value
                
                NavigationLink(value: "WorkoutDetail") {
                    Text("Go to Back Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 250)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
            // Handling the navigation destination based on value
            .navigationDestination(for: String.self) {
                value in
                if value == "WorkoutDetail" {
                    WorkoutDetailView()
                }
            }
        }
    }
}


/// Reusable Exercise Card
struct ExerciseCardView: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 16) {
            // Exercise Image Placeholder
            ZStack {
                Color.white
                Image(systemName: "figure.strengthtraining.traditional")
                    .resizable()
                    .scaledToFit()
                    .padding(12)
                    .foregroundColor(.black)
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text("\(exercise.setData[0].sets) sets \(exercise.setData[0].reps) reps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Right Icon
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "viewfinder")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                )
        }
        .padding(12)
        .background(Color(UIColor.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}

// MARK: - Exercise Detail Page (Destination)
struct ExerciseDetailView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.strengthtraining.traditional")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .foregroundColor(.orange)
                .padding()
                
            Text(exercise.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(exercise.setData[0].sets)")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview Provider
struct ScheduledPresetView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledPresetView()
    }
}
