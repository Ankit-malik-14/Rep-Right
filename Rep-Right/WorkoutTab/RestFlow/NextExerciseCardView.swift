//
//  NextExerciseCardView.swift
//  Rep-Right
//
//  Created by Jugad on 22/03/26.
//
import SwiftUI

struct NextExerciseCardView: View {
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 24)
                .frame(width: .infinity, height: 80)
                .foregroundStyle(.gray.secondary)
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .frame(width: 65, height: 65)
                    .overlay(
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.title)
                            .foregroundStyle(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Deadlift")
                        .font(.title3)
                    
                    Text("4 sets 10 reps")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // assistance indication
                    Image(systemName: "viewfinder")
                        .font(.title3.weight(.semibold))
                        .padding(12)
                        .background(.orange.opacity(0.25), in: Circle())
                        .foregroundStyle(.orange)
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

#Preview {
    NextExerciseCardView()
}
