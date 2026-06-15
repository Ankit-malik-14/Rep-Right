//
//  SchedulerView.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-31.
//

import SwiftUI

struct SchedulerView: View {
    @Environment(WeeklySchedules.self) private var schedules
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(Presets.self) private var presets
    @Environment(Exercises.self) private var exercises
    @Environment(UserProfileModel.self) private var profile
    var contextPreset: Preset? = nil
    
    @State private var viewModel: SchedulerViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                SchedulerViewContent(contextPreset: contextPreset)
                    .environment(viewModel)
            } else {
                Color.clear
                    .onAppear {
                        viewModel = SchedulerViewModel(
                            weeklySchedules: schedules,
                            summaryManager: summaryManager,
                            presets: presets,
                            exercises: exercises,
                            userProfile: profile
                        )
                    }
            }
        }
    }
}

struct SchedulerViewContent: View {
    @Environment(SchedulerViewModel.self) private var viewModel
    var contextPreset: Preset? = nil
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Need a routine? Your smart week rotates fresh muscle groups and schedules recovery automatically.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Smart Schedule") {
                            viewModel.applySmartSchedule()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    ForEach(Weekday.allCases, id: \.self) { weekday in
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
    NavigationStack {
        SchedulerView()
            .environment(Presets())
            .environment(WeeklySchedules())
            .environment(WorkoutSummaryManager())
            .environment(Exercises())
            .environment(UserProfileModel())
    }
}

