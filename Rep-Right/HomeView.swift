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
        }
    }
}

#Preview {
    HomeView()
}
