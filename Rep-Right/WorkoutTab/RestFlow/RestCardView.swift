/* DEPRECATED: Replaced by WorkoutRestScreen. Rest flow logic moved into ActiveWorkoutView.
//
//  RestCardView.swift
//  Rep-Right
//
//  Created by Jugad on 22/03/26.
//

import SwiftUI

struct RestCardView: View {

    @Binding var dismissSheet: Bool
    @Binding var isLastSet: Bool
    @State var restTime: Int = 180
    @State var isRunning: Bool = true
    
    var body: some View {
        ZStack{
        VStack(spacing: 15) {
            RestTimerView2(timeRemaining: $restTime, isRunning: $isRunning)
                .padding(.top,30)
            
            HStack {
                Button {
                    if restTime > 60 {
                        restTime = restTime - 60
                    }
                    else {
                        restTime = 0
                        Task{
                            try? await Task.sleep(for: .milliseconds(400))
                            dismissSheet.toggle()
                        }
                    }
                } label: {
                    VStack {
                        ZStack {
                            Circle()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(.gray.opacity(0.3))
                            Image(systemName: "minus")
                                .padding(20)
                                .fontWeight(.heavy)
                                .foregroundStyle(.black)
                        }
                    }
                }.padding()
                
                Button {
                    isRunning.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: 85, height: 85)
                            .foregroundStyle(.red)
                        Image(systemName: isRunning ? "pause" : "play.fill")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)
                
                Button {
                    restTime = restTime + 60
                } label: {
                    VStack {
                        ZStack {
                            Circle()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(.gray.opacity(0.3))
                            Image(systemName: "plus")
                                .padding(20)
                                .fontWeight(.heavy)
                                .foregroundStyle(.black)
                        }
                    }
                }
                .padding()
                
            }
            
            if isLastSet {
                NextExerciseCardView()
            }
            Button(action: {
                dismissSheet.toggle()
            }) {
                Text("Skip")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .clipShape(.rect(cornerRadius: 30))
            }
            .padding(.horizontal,20)
            .buttonStyle(.glass)
        }
    }
            .padding(.horizontal)

        }
    }


#Preview {
    @Previewable @State var showSheet = false
    @Previewable @State var isLastSet = false
    RestCardView(dismissSheet: $showSheet, isLastSet: $isLastSet)
}
*/
