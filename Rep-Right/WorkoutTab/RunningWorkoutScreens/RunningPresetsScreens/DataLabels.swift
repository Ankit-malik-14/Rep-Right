//
//  DataLabels.swift
//  Rep-Right
//

import SwiftUI

struct DataLabels: View {
    // Fetched from ActiveWorkoutState: elapsed time in seconds
    var timeElapsed: TimeInterval
    // Fetched from ActiveWorkoutState: workout completion progress (0.0–1.0)
    var progress: Double = 0.0
    // Fetched from ActiveWorkoutState: estimated calories burned so far
    var calories: Int = 0
    
    var timeString: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        LazyHGrid(rows: [GridItem(.flexible())], alignment: .center, spacing: 20) {
            //timer — Fetched from ActiveWorkoutState: timeElapsed
            Label {
                Text(timeString)
            } icon: {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
            }
            .padding(10)
            .background(.secondary.opacity(0.2))
            .clipShape(.capsule)
            
            //Progress — Fetched from ActiveWorkoutState: progress percentage
            Label {
                Text("\(Int(progress * 100)) %")
            } icon: {
                Image(systemName: "chart.bar.horizontal.page.fill")
                    .foregroundStyle(.orange)
            }
            .padding(10)
            .background(.secondary.opacity(0.2))
            .clipShape(.capsule)
            
            //Calories — Fetched from ActiveWorkoutState: estimated calorie burn
            Label {
                Text(calories > 0 ? "\(calories)" : "--")
            } icon: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }
            .padding(10)
            .background(.secondary.opacity(0.2))
            .clipShape(.capsule)
            
        }.frame(maxHeight: 50)
    }
}
