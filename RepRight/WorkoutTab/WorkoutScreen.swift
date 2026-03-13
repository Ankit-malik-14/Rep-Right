//
//  WorkoutScreen.swift
//  RepRight
//
//  Created by Mayurakshi Das on 09/03/26.
//

import SwiftUI

struct WorkoutScreen: View {
    var body: some View {
        VStack{
//                    ScrollView{
            
                ScheduledWorkout()
                
                Custom_Preset()
            
                Presets_Bodyparts()
            
//                    }.scrollIndicators(.hidden)
        }
    }
}

#Preview {
    WorkoutScreen()
}
