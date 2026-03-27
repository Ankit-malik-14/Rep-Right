//
//  WorkoutScreen.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

enum nums: Int{
    case first = 1
    case second = 2
    case thirds = 3
}

struct WorkoutScreen: View {
    var body: some View {
        
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading){
                    
                    ScheduledWorkoutCard()
                    
                    CustomPreset()
                    
                    DefaultPresets()
                    HStack{
                        Text("Exercises")
                            .font(.largeTitle.bold())
                            .padding(.horizontal)
                        Spacer()
                        Button("See all") {
                            //
                        }.tint(.orange)
                            .padding(.horizontal)
                    }
                    ExerciseListView()
                }
            }.navigationDestination(for: Preset.self, destination: { preset in
                
            })
            .navigationTitle("Workouts")
        }
        .toolbar{
            ToolbarItem {
                    Image(systemName: "person.circle")
            }
        }
    }
}

#Preview {
//    @Previewable @Environment(WeeklySchedules.self) var weeklySchedules
//    @Previewable @Environment(Presets.self) var preset
//    @Previewable @Environment(Exercises.self) var exercises
    NavigationStack{
        WorkoutScreen()
            .environment(WeeklySchedules())
            .environment(Presets())
            .environment(Exercises())
    }
}
