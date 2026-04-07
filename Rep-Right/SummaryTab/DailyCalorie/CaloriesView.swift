//
//  CaloriesView.swift
//  Rep_Right
//
//  Created by GU on 01/04/26.
//
import SwiftUI

struct CaloriesView: View {
    @State private var value = 100
    //@Binding var currentCalorieBurn: Int
    //@Binding var goal: Int
    
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.ultraThinMaterial)
                        .frame(height: 250)
                        .padding(.horizontal)
                    
                    Gauge(value:100, in: 0...1000) {
                    }
                    //replace with Gauge(value: $currentCalorieBurn, in: 0...$goal)
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(.orange
                    )
                    .scaleEffect(3.5)
                    
                    Image(systemName: "flame.fill")
                }
                MoveDataView(cal: $value)
            }
           // NavigationLink(value: ) {
                //clipShape(.capsule)
            //}
        }
    }
}

#Preview {
    CaloriesView()
        .environment(Exercises())
}
