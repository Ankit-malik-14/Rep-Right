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
    
//    let exercisee = Exercise(
//        name: "Push-Up",
//        targetAreas: ["Chest", "Triceps", "Shoulders", "Core"],
//        equipments: ["Bodyweight"],
//        executionSteps: [
//            "Start in a high plank with hands slightly wider than shoulder-width.",
//            "Brace your core and keep a straight line from head to heels.",
//            "Lower your chest toward the floor by bending your elbows.",
//            "Press through your palms to return to the starting position.",
//        ],
//        tips: [
//            "Keep elbows at ~45° from your torso.",
//            "Do not let hips sag; maintain a neutral spine.",
//            "Inhale on the way down, exhale as you press up.",
//        ],
//        assistanceAvailable: true,
//        demoVideo: URL(string: "https://example.com/videos/pushup.mp4"),
//        setData: [
//            SetData(sets: 3, reps: 12),
//            SetData(sets: 1, reps: 10),
//        ]
//    )

    var body: some View {
        ZStack{
           // RoundedRectangle(cornerRadius: 20)
                //.frame(maxWidth: .infinity,maxHeight: 400)
               // .foregroundStyle(.ultraThinMaterial.opacity(0.5))
            
        
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
                        Image(systemName: isRunning ? "pause" : "play.fill")  //needs ternary play pause logic
                        //.padding(20)
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
            
            //ternary-type logic for next exercise card
            if isLastSet {
                NextExerciseCardView()
            }
            Button(action: {
                dismissSheet.toggle()
            }) {
                Text("Skip")
                    .font(.system(size: 20, weight: .bold))
                //.foregroundStyle(.primary)
                //.background(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    
                //.background(Color.orange)
                //.background(.secondary)
                    .clipShape(.rect(cornerRadius: 30))
            }
            .padding(.horizontal,20)
            
            .buttonStyle(.glass)
            
            /*
             Button {
             dismissSheet.toggle()
             } label: {
             ZStack {
             RoundedRectangle(cornerRadius: 8)
             .frame(width: .infinity, height: 60)
             .foregroundStyle(.orange)
             //.padding(.horizontal)
             HStack {
             Text("Skip")
             //Image(systemName: "chevron.right.2")
             }
             .foregroundStyle(.black)
             .fontWeight(.bold)
             }
             */
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
