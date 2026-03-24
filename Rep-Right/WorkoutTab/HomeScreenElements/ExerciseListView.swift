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
                    ZStack(alignment:.leading){
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                        HStack(alignment: .center){
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 70, height: 70)
                                .foregroundStyle(.background.tertiary)
                                .padding(6)
                            VStack(alignment: .leading){
                                Text(exercise.name)
                                    .font(.title2)
                                Text(exercise.targetAreas[0])
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if exercise.assistanceAvailable{
                                assisstanceAvailablityTag(type: .icon).padding(.horizontal)
                            }
                            
                        }
                    }.padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
//    @Previewable @Environment(Exercises.self) var exercises
    ExerciseListView()
        .environment(Exercises())
}
