//
//  AccuracyMeterView.swift
//  Rep-Right
//
//  Created by GU on 17/03/26.
//

import SwiftUI

struct AccuracyMeterView: View {
    @State var value: Double
    
    var body: some View {
        VStack{
            ScrollView{
                GaugesView(value: $value)
                MotivationalQuote(value:$value)
                LevelView(value: $value)
                PossibleRisk()
                SuggestionView()
            }
        }
    }
}

#Preview {
    
    AccuracyMeterView(value: 82.0)
}
