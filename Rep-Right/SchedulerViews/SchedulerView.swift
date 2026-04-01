//
//  SchedulerView.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-31.
//

import SwiftUI

struct SchedulerView: View {
    var body: some View {
        VStack{
            ForEach(Weekday.allCases,id: \.self){ weekday in
                ZStack(alignment: .topLeading){
                    switch weekday{
                        case .monday:
                        Text("Monday").font(.caption).bold().foregroundStyle(.orange)
                        case .tuesday:
                        Text("Tuesday").font(.caption).bold().foregroundStyle(.orange)
                        case .wednesday:
                            Text("Wednesday").font(.caption).bold().foregroundStyle(.orange)
                        case .thursday:
                            Text("Thursday").font(.caption).bold().foregroundStyle(.orange)
                        case .friday:
                            Text("Friday").font(.caption).bold().foregroundStyle(.orange)
                        case .saturday:
                            Text("Saturday").font(.caption).bold().foregroundStyle(.orange)
                        case .sunday:
                            Text("Sunday").font(.caption).bold().foregroundStyle(.orange)
                    }
                    
                }
                
            }
        }
    }
}

#Preview {
    NavigationStack{
        SchedulerView()
    }
}
