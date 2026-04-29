//
//  MetricsTabViewContainer.swift
//  Rep-Right
//
//  Created by GU on 23/03/26.
//

import SwiftUI

struct MetricsTabViewContainer: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ExerciseRingView()
                TotalTimeExerciseView()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .navigationTitle("Metrics")
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    NavigationStack{
        MetricsTabViewContainer()
            .environment(WorkoutSummaryManager())
            .environment(Exercises())
    }
}
