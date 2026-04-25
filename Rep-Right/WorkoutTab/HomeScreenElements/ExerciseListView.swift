//
//  ExerciseListView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct ExerciseListView: View {
    @Environment(Exercises.self) var exercises
    var body: some View {
        VStack(alignment: .leading){
            ScrollView(.vertical){
                ForEach(exercises.exerciseList){ exercise in
                    NavigationLink(value: exercise) {
                        HStack(alignment: .center){
                            RoundedRectangle(cornerRadius: 16)
                            
                                .frame(width: 67, height: 64)
                                .shadow(radius: 100)
                                .foregroundStyle(.background.tertiary)
                                .padding(6)
                            VStack(alignment: .leading){
                                Text(exercise.name)
                                    .font(.headline)
                                Text(exercise.primaryFocusArea?.rawValue ?? exercise.targetAreas[0])
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if exercise.assistanceAvailable{
                                assisstanceAvailablityTag(type: .icon).padding(.horizontal)
                            }
                            
                        }.background(RoundedRectangle(cornerRadius: 20).foregroundStyle(.background.secondary)).padding(.horizontal)
                    }.buttonStyle(.plain)
                    
                }.navigationDestination(for: Exercise.self) { exercise in
                    ExercisesView(exercise: exercise)
                }
            }
        }
    }
}

#Preview {
    ExerciseListView()
        .environment(Exercises())
}
