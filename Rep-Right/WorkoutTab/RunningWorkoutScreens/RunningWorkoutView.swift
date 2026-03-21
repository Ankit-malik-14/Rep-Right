//
//  RunningWorkoutView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 19/03/26.
//

import SwiftUI

struct RunningWorkoutView: View {
    var body: some View {
//        ScrollView{
            VStack {
                //Labels
                DataLabels()
                ImageAndInfoCard()
                RunningWorkoutInfo()
            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal, 16)
//            .padding(.vertical, 12)
//        }.scrollIndicators(.hidden)
    }
}

#Preview {
    RunningWorkoutView()
        
}
