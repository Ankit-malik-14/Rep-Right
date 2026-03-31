//
//  RestTimerView.swift
//  Rep-Right
//
//  Created by Jugad on 22/03/26.
//
/*
 import SwiftUI
 import Combine
 
 struct RestTimerView: View {
 @Binding var timeRemaining: Int
 //publisher that fires every second
 let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
 //    let time = Timer
 var body: some View {
 
 Text(timeString(from: timeRemaining))
 .font(.system(size: 100))
 .fontWeight(.bold)
 .foregroundStyle(.orange)
 .onReceive(timer) { _ in
 if timeRemaining > 0 {
 timeRemaining -= 1
 }
 }
 }
 
 private func timeString(from seconds: Int)-> String {
 let minutes = seconds / 60
 let second = seconds % 60
 return String(format: "%02d : %02d", minutes,second)
 }
 }
 
 #Preview {
 @Previewable @State var someTime = 300
 RestTimerView(timeRemaining: $someTime)
 }
 */
