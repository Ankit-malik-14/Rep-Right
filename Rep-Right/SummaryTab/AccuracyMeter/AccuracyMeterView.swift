//
//  AccuracyMeterView.swift
//  Rep-Right
//

import SwiftUI

struct AccuracyMeterView: View {
    @State var value: Double
    // Fetched from DataModel: exercise name passed from parent navigation
    var exerciseName: String
    
    var body: some View {
        VStack{
            NavigationStack{
                ScrollView{
                    GaugesView(value: $value)
                        .padding(.vertical)
                    LevelView(value: $value)
                    MotivationalQuote(value:$value)
                        .padding(.vertical)
                    RiskView()
                    SuggestionView()
                }
                // Fetched from DataModel: dynamic exercise name instead of hardcoded "Exercise Name"
                .navigationTitle(exerciseName)
                .font(.system(size: 20, weight: .bold, design: .default))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    AccuracyMeterView(value: 30.0, exerciseName: "Push-Up")
}
