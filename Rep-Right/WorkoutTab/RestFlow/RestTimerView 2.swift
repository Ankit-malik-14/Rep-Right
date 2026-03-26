//
//  RestTimerView 2.swift
//  Rep-Right
//
//  Created by Jugad on 25/03/26.
//


import SwiftUI
import Combine

struct RestTimerView2: View {
    @Binding var timeRemaining: Int
    @Binding var isRunning: Bool
    
    // This holds our timer so we can cancel (invalidate) it
    @State private var timerSubscription: AnyCancellable?
    
    var body: some View {
        Text(timeString(from: timeRemaining))
            .font(.system(size: 100))
            .fontWeight(.bold)
            .foregroundStyle(.orange)
            .onAppear {
                if isRunning { startTimer() }
            }
            .onChange(of: isRunning) { oldValue, newValue in
                if newValue {
                    startTimer()
                } else {
                    stopTimer()
                }
            }
    }
    
    private func startTimer() {
        // Creating the timer subscription
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    stopTimer()
                }
            }
    }
        
    private func stopTimer() {
        //works similar to invalidate()
        timerSubscription?.cancel()
        timerSubscription = nil
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let second = seconds % 60
        return String(format: "%02d : %02d", minutes, second)
    }
}

#Preview {
    @Previewable @State var someTime = 10
    @Previewable @State var runStat = true
    RestTimerView2(timeRemaining: $someTime, isRunning: $runStat)
}
