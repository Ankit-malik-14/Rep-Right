//
//  SchedulerView.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-31.
//

import SwiftUI

struct SchedulerView: View {
    @Environment(WeeklySchedules.self) var schedules
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(Presets.self) private var presets
    @Environment(Exercises.self) private var exercises
    @Environment(UserProfileModel.self) private var profile
    @Environment(\.dismiss) private var dismiss
    var contextPreset: Preset? = nil
    
    private var recommendedSchedule: [ScheduledPresetRecommendation] {
        summaryManager.generatedWeeklySchedule(
            from: presets.presets,
            using: exercises.exerciseList,
            trainingDays: profile.weeklyGoalDays
        )
    }
    
    var body: some View {
        NavigationStack{
        VStack(alignment: .leading){
//                Text("Scheduler")
//                    .font(.largeTitle).bold()
//                    .padding([.top,.leading,.trailing])
                
                ScrollView{
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Need a routine? Your smart week rotates fresh muscle groups and schedules recovery automatically.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Smart Schedule") {
                            schedules.apply(recommendedSchedule)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    ForEach(Weekday.allCases,id: \.self){ weekday in
                        SchedulerCards(weekday: weekday, contextPreset: contextPreset)
                            .padding(.horizontal)
                    }
                }
            }
                .navigationTitle("Scheduler")
                
        }
    }
}

#Preview {
    NavigationStack{
        SchedulerView()
            .environment(Presets())
            .environment(WeeklySchedules())
            .environment(WorkoutSummaryManager())
            .environment(Exercises())
    }
}
