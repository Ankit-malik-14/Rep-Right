
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
        VStack(spacing: 0) {
            ForEach(Array(exercises.exerciseList.prefix(4).enumerated()), id: \.element.id) { index, exercise in
                NavigationLink(value: WorkoutRoute.exerciseDetail(exercise)) {
                    HStack(alignment: .center, spacing: 12) {
                        if let img = exercise.image {
                            Image(img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.tertiarySystemFill))
                                .frame(width: 50, height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Color(.label))
                            Text(exercise.primaryFocusArea?.rawValue ?? exercise.targetAreas.first ?? "")
                                .font(.footnote)
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        
                        Spacer()
                        
                        if exercise.assistanceAvailable {
                            assisstanceAvailablityTag(type: .icon)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.secondarySystemBackground))
                }
                .buttonStyle(.plain)
                
                if index < 3 { // Assuming prefix(4), the last index is 3
                    Divider()
                        .padding(.leading, 78)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }
}

#Preview {
    ExerciseDisclosedListView()
        .environment(Exercises())
}
