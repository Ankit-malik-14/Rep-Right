//
//  MoveDataView.swift
//  Rep_Right
//

import SwiftUI

struct MoveDataView: View {
    // Fetched from SummaryDataModel: current calorie burn value
    var cal: Int
    // Fetched from SummaryDataModel: daily calorie goal
    var goal: Int
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Move")
                .font(.callout)
                .fontWeight(.light)
            HStack{
                // Fetched from SummaryDataModel: todayCaloriesBurned / dailyCalorieGoal
                Text("\(cal)/\(goal)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                Text("CAL")
                    .font(.title3)
                    .fontWeight(.light)
            }
        }
        .padding()
    }
}

#Preview {
    MoveDataView(cal: 100, goal: 500)
}
