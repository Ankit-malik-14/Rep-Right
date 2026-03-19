//
//  WarmUpExerciseRowView.swift
//  Rep-Right
//
//  Created by GU on 19/03/26.
//

import SwiftUI

struct WarmUpExerciseRowView: View {
    let exercise: WarmUpExercise
    
    var body: some View {
        HStack(spacing: 16) {
            // Exercise Image Placeholder
            ZStack {
                Color.white
                Image(systemName: exercise.systemImage)
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
                Text(exercise.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Right Icon (Hamburger Menu)
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.gray)
                .font(.system(size: 20))
                .padding(.trailing, 8)
        }
        .padding(12)
        .background(Color(UIColor.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}
