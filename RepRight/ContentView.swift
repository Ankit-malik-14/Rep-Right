//
//  ContentView.swift
//  RepRight
//
//  Created by Mayurakshi Das on 30/01/26.
//

import SwiftUI

struct ContentView: View {
    
    enum RepRightTab{
        case workout
        case summary
    }
    @State private var selectedTab: RepRightTab = .workout
    var body: some View {
        VStack{
            TabView(selection: $selectedTab) {
                Tab("Workout", systemImage: "dumbbell.fill", value: .workout) {
                    ScheduledWorkout()
                }
                Tab("summary", systemImage: "list.clipboard", value: .summary) {
                    Text("Summary page to be called")
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
