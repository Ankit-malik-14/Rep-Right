//
//  GaugesView.swift
//  Rep-Right
//
//  Created by GU on 17/03/26.
//

import SwiftUI

struct GaugesView: View {
    
   @State var value: Double
    var body: some View {
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .frame(height: 350)
                    .padding(.horizontal)
                    .foregroundStyle(.background.secondary)
                Gauge(value: value, in: 0...100) {
                }
                .gaugeStyle(.accessoryCircular)
                .tint(
                    Gradient(colors: [
                        .red,
                        .yellow,
                        .green
                    ])
                )
                .scaleEffect(5)
                
                Text("\(Int(value))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
            }

        }
    
    }
}


#Preview {
    GaugesView(value: 30)
}
