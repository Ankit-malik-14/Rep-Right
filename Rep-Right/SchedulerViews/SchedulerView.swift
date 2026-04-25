//
//  SchedulerView.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-31.
//

import SwiftUI

struct SchedulerView: View {
    @Environment(WeeklySchedules.self) var schedules
    @Environment(\.dismiss) private var dismiss
    var contextPreset: Preset? = nil
    
    var body: some View {
        //NavigationStack{
        VStack(alignment: .leading){
                Text("Scheduler")
                    .font(.largeTitle).bold()
                    .padding([.top,.leading,.trailing])
                ScrollView{
                    ForEach(Weekday.allCases,id: \.self){ weekday in
                        SchedulerCards(weekday: weekday, contextPreset: contextPreset)
                            .padding(.horizontal)
                    }
                }
            }
                //.navigationTitle("Scheduler")
        //}
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
