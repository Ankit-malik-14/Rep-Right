//
//  CalibrationScreen2.swift
//  Rep-Right
//
//  Created by Jugad on 27/03/26.
//

import SwiftUI
import Combine

struct CalibrationScreen2: View {
    @State var timerTime: Int = 3
    @State private var timerSubscription: AnyCancellable?
    
    var body: some View {
        ZStack(){
            Color.gray.ignoresSafeArea()//image preview or camera preview
            VStack(spacing: 220){
                HStack{
                    Spacer()
                    Button {
                        // willl show tips
                    } label: {
                        HStack{
                            Image(systemName: "lightbulb.max.fill")
                            Text("Tips")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.orange)
                    .buttonStyle(.bordered)
                    .padding(.trailing,30)

                }
                Text("\(timerTime)")
                    .font(.system(size: 100))
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                
                    
                //Timer for 3seconds
                HStack{
                    VStack(spacing: 50){
                        Text("Detection starting ...")
                        HStack{
                            ForEach(1...3, id: \.self) { index in
                                Capsule()
                                    .fill(index == 3-timerTime ? Color.orange : Color.orange.opacity(0.3))
                                    .frame(width: 100, height: 8)
                            }
                        }
                    }
                }
                .frame(width: 380, height: 150)//can't put .infinity as width 
                .background(.secondary, in: RoundedRectangle(cornerRadius: 16))
                
            }
            
        }
        .onAppear {
                    startTimer()
                }
        .onDisappear {
            timerSubscription?.cancel()
        }
        
    }
    
    private func startTimer() {
        // Creating the timer subscription
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timerTime > 0 {
                    timerTime -= 1
                }
            }
    }
    
}

#Preview {
    CalibrationScreen2()
}
