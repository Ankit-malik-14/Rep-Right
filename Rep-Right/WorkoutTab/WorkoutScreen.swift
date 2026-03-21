//
//  WorkoutScreen.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct WorkoutScreen: View {
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading){
                    
                    ScheduledWorkoutCard()
                    
                    CustomPreset()
                    
                    PresetsAccordingToBodyParts()
                    HStack{
                        Text("Exercises")
                            .font(.largeTitle.bold())
                            .padding()
                        Spacer()
                        Button("See all") {
                            //
                        }.tint(.orange)
                        .padding()
                    }
                    ExerciseListView()
                }
            }.navigationTitle("Workouts")
        }
    }
}

#Preview {
    @Previewable @Environment(WeeklySchedules.self) var weeklySchedules
    @Previewable @Environment(Presets.self) var preset
    @Previewable @Environment(Exercises.self) var exercises
    WorkoutScreen()
        .environment(weeklySchedules)
        .environment(preset)
        .environment(exercises)
}
