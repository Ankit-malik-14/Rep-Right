//
//  HomeView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            Tab("Workout", systemImage: "dumbbell.fill"){
                WorkoutScreen()
            }
            Tab("Summary", systemImage: "list.clipboard.fill"){
                SummaryTabView()
            }
//            Tab("Profile", systemImage: "person.fill"){
//                ProfileFormView()
//            }
        }
    }
}

#Preview {
    HomeView()
        .environment(Presets())
        .environment(Exercises())
        .environment(WeeklySchedules())
        .environment(CustomPresetsDummyData())
        .environment(WorkoutSummaryManager())
        .environment(UserProfileModel())
}
