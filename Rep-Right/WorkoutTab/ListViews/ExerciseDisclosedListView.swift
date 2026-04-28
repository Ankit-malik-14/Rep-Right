
//
//  Created by Jugad on 26/04/26.

//
//  ExerciseListView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct ExerciseDisclosedListView: View {
    @Environment(Exercises.self) var exercises
    var body: some View {
        VStack(alignment: .leading){
            ScrollView(.vertical){
                ForEach(exercises.exerciseList.prefix(4)){ exercise in
                    NavigationLink(value: WorkoutRoute.exerciseDetail(exercise)) {
                        HStack(alignment: .center){
                           
                            Image(exercise.image ?? "Placeholder")
                                    .resizable().clipShape(RoundedRectangle(cornerRadius: 16))
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
                    
                }
            }
        }
    }
}

#Preview {
    ExerciseDisclosedListView()
        .environment(Exercises())
}
