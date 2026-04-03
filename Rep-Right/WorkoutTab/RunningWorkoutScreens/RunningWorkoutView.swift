//
//  RunningWorkoutView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 19/03/26.
//

import SwiftUI

struct RunningWorkoutView: View {
    var preset: Preset
    var body: some View {
        VStack{
            //Labels
            DataLabels()
                .padding()
            ImageAndInfoCard(preset: preset)
                .padding(3)
            RunningWorkoutInfo()
                .padding(3)
            }
    }
}

#Preview {
    RunningWorkoutView(preset: Presets().presets[2])
        
}
