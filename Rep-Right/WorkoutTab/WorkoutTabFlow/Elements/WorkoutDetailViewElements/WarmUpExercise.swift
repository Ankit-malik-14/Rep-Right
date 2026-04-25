//
//  WarmUpExercise.swift
//  PresettFlow
//
//  Created by Jugad on 17/03/26.
//
//MARK: - File Structure
//      1. Data Models
//      2. Main Warmup View File
//      3. Modular Subview
//      



import SwiftUI

// MARK: - Data Models
struct WarmUpExercise: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let systemImage: String
}

// MARK: - Main Warm Up View
struct WarmUpView: View {
    // Mock Data based on the image
    let warmupExercises = [
        WarmUpExercise(name: "Glute Bridge", subtitle: "3 sets 12 reps", systemImage: "figure.pilates"),
        WarmUpExercise(name: "Shoulder Stretch", subtitle: "3 sets 12 reps", systemImage: "figure.flexibility"),
        WarmUpExercise(name: "Side Stretch", subtitle: "3 sets 12 reps", systemImage: "figure.flexibility"),
        WarmUpExercise(name: "Oblique Stretch", subtitle: "3 sets 12 reps", systemImage: "figure.flexibility")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // 1. Header & Stats Section (Overlapping)
                VStack(spacing: -50) {
                    WarmUpHeaderView()
                    WarmUpStatsCardView()
                }
                .padding(.horizontal)
                
                // 2. Start Session Button
                Button(action: {
                    print("Start Session Tapped")
                }) {
                    Text("Start Session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // 3. Exercises List
                VStack(spacing: 16) {
                    HStack {
                        Text("Exercises")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Text("\(warmupExercises.count) total")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(warmupExercises) { exercise in
                        WarmUpExerciseRowView(exercise: exercise)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
            .padding(.top, 10)
        }
        .navigationTitle("Warm Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Modular Subviews

/// The pale orange top header card
struct WarmUpHeaderView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            Color.orange.opacity(0.25)
            
            VStack(alignment: .leading) {
                // Center Icon
                HStack {
                    Spacer()
                    Image(systemName: "figure.gymnastics") // Close approximation to the stretching figure
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Bottom Left Text (Sits right above the overlapping stats card)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Warm up")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Heat up the body")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 70) // Extra padding to account for the overlapping card
            }
        }
        .frame(height: 280)
        .cornerRadius(20)
    }
}

/// Stats Grid View for Warm Up (No Schedule Button)
struct WarmUpStatsCardView: View {
    var body: some View {
        VStack {
            // Using Grid for perfect 2x2 alignment
            Grid(alignment: .leading, horizontalSpacing: 80, verticalSpacing: 24) {
                GridRow {
                    WarmUpStatItemView(icon: "flame.fill", title: "Calories", value: "100 kcal")
                    WarmUpStatItemView(icon: "clock", title: "Time", value: "15 mins")
                }
                GridRow {
                    WarmUpStatItemView(icon: "dumbbell.fill", title: "Equipment", value: "-/-")
                    WarmUpStatItemView(icon: "figure.walk", title: "Target", value: "Body")
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
        }
        //.frame(maxWidth: .infinity)
        .frame(width: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 10)
    }
}

/// Reusable helper for stat items
struct WarmUpStatItemView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.orange)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
    }
}

/// Reusable Exercise Row for Warm Ups


// MARK: - Preview Provider
struct WarmUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WarmUpView()
        }
    }
}
