//
//  MetricsTabViewContainer.swift
//  Rep-Right
//
//  Created by GU on 23/03/26.
//

import SwiftUI

struct MetricsTabViewContainer: View {
    var body: some View {
    ScrollView{
            VStack(spacing: 20){
                ExerciseRingView()
                Spacer()
                Spacer()
            TotalTimeExerciseView()
            }.navigationTitle("Metrics")
    }
    }
}

#Preview {
    NavigationStack{
        MetricsTabViewContainer()
    }
}

