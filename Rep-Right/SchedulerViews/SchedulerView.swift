//
//  SchedulerView.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-31.
//

import SwiftUI

struct SchedulerView: View {
    @Environment(WeeklySchedules.self) var schedules
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView{
                    ForEach(Weekday.allCases,id: \.self){ weekday in
                        SchedulerCards(weekday: weekday).padding(.horizontal)
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
            .environment(WeeklySchedules())
            .environment(Presets())
    }
}
