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
                    .padding(.vertical)
                LevelView(value: $value)
                Divider()
                MotivationalQuote(value:$value)
                Divider()
                    .padding(.vertical)
                RiskView()
                    
                SuggestionView()
            }
        }
    }
}

#Preview {
    
    AccuracyMeterView(value: 10.0)
}
