//
//  WorkoutScreen.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct WorkoutScreen: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading){
                
                ScheduledWorkoutCard()
                
                CustomPreset()
                
                PresetsAccordingToBodyParts()
                
                ExerciseList()
            }
        }
    }
}

#Preview {
    WorkoutScreen()
}
