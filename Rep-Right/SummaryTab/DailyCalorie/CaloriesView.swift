//
//  CaloriesView.swift
//  Rep_Right
//

import SwiftUI

struct CaloriesView: View {
    // Fetched from SummaryDataModel: reads today's calorie burn and goal
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.ultraThinMaterial)
                        .frame(height: 250)
                        .padding(.horizontal)
                    
                    // Fetched from SummaryDataModel: todayCaloriesBurned / dailyCalorieGoal
                    Gauge(value: summaryManager.todayCaloriesBurned, in: 0...summaryManager.dailyCalorieGoal) {
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(.orange)
                    .scaleEffect(3.5)
                    
                    Image(systemName: "flame.fill")
                }
                // Fetched from SummaryDataModel: todayCaloriesBurned for display, dailyCalorieGoal for target
                MoveDataView(cal: Int(summaryManager.todayCaloriesBurned), goal: Int(summaryManager.dailyCalorieGoal))
            }
        }
    }
}

#Preview {
    CaloriesView()
        .environment(WorkoutSummaryManager())
}
