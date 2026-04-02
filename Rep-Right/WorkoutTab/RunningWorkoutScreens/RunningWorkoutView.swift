//
//  RunningWorkoutView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 19/03/26.
//

import SwiftUI

struct RunningWorkoutView: View {
    var body: some View {

            VStack {
                //Labels
                DataLabels()
                    .padding()
                ImageAndInfoCard()
                    .padding(4)
                RunningWorkoutInfo()
                    .padding(3)
            }

    }
}

#Preview {
    RunningWorkoutView()
        .environment(Presets())
}
