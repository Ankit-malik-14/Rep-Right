//
//  WorkoutScreen.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

enum ExpandedViews{
    case customPresets
    case defaultPresets
    case ExerciseList
}
enum ClickedPresetDestination{
    case presetInfo
    case startPreset
}

struct WorkoutScreen: View {
    @Environment(Exercises.self) var exercises
    @Environment(Presets.self) var preset
    @Environment(CustomPresetsDummyData.self) var customPresets
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading){
                    
                    ScheduledWorkoutCard()
                    
                    CustomPreset(preset: customPresets)
                    
                    DefaultPresets(preset: preset)
                    HStack{
                        Text("Exercises")
                            .font(.title.bold())
                            .padding(.horizontal)
                        Spacer()
                        Button("See all") {
                            //
                        }.tint(.orange)
                            .padding(.horizontal)
                    }
                    ExerciseListView()
                }
            }.navigationDestination(for: ExpandedViews.self, destination: { view in
                switch view {
                case .ExerciseList:
                    ExerciseListView()
                case .customPresets:
                    CustomPresetsListView(preset: customPresets)
                case .defaultPresets:
                    DefaultPresetListView(presets: preset)
                }
            })
            .navigationTitle("Workouts")
            .toolbar{
                ToolbarItem {
                    Image(systemName: "person.circle")
                }
            
            }

        }
    }
}

#Preview {
    NavigationStack{
        WorkoutScreen()
            .environment(CustomPresetsDummyData())
            .environment(WeeklySchedules())
            .environment(Presets())
            .environment(Exercises())
    }
}
