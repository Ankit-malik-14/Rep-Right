//
//  ExerciseListView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct ExerciseListView: View {
    @Environment(Exercises.self) var exercises
    @State private var searchFieldText: String = ""
    
    var searchResults: [Exercise] {
        if searchFieldText.isEmpty {
            return exercises.exerciseList
        } else {
            return exercises.exerciseList.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(searchFieldText)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if searchResults.isEmpty {
                ContentUnavailableView.search(text: searchFieldText)
            } else {
                ScrollView(.vertical) {
                    ForEach(searchResults) { exercise in
                        NavigationLink(value: WorkoutRoute.exerciseDetail(exercise)) {
                            HStack(alignment: .center) {
                                
                                Image(exercise.image ?? "Placeholder")
                                    .resizable().clipShape(RoundedRectangle(cornerRadius: 16))
                                    .frame(width: 67, height: 64)
                                    .shadow(radius: 100)
                                    .foregroundStyle(.background.tertiary)
                                    .padding(6)
                                
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .font(.headline)
                                    Text(exercise.primaryFocusArea?.rawValue ?? exercise.targetAreas[0])
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if exercise.assistanceAvailable {
                                    assisstanceAvailablityTag(type: .icon).padding(.horizontal)
                                }
                                
                            }
                            .background(RoundedRectangle(cornerRadius: 20).foregroundStyle(.background.secondary))
                            .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .scrollIndicators(.never)
            }
        }
        .searchable(text: $searchFieldText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Name of exercise")
        .navigationTitle("Exercises")
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
            .environment(Exercises())
    }
}
