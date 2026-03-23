//
//  ExerciseDetailView.swift
//  Rep-Right
//
//  Created by GU on 19/03/26.
//

import SwiftUI

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
