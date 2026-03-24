//
//  ExerciseCardView.swift
//  Rep-Right
//
//  Created by GU on 19/03/26.
//
 import SwiftUI

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

#Preview {
    ExerciseCardView(exercise: Presets().presets[0].exercises[0])
}
//fetch from environment
