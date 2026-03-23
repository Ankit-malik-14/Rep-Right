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
        VStack(spacing: 15) {
            RestTimerView(timeRemaining: $restTime)

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
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.orange.opacity(0.2))
                            Image(systemName: "minus")
                                .padding(20)
                                .fontWeight(.heavy)
                                .foregroundStyle(.black)
                        }
                        Text("-1 MIN")
                            .font(.footnote)
                            .fontWeight(.black)
                            .foregroundStyle(.black)
                    }
                }.padding()

                Button {
                    isRunning.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: 85, height: 85)
                            .foregroundStyle(.orange)
                        Image(systemName: isRunning ? "pause" : "play.fill")  //needs tertiary play pause logic
                            .padding(20)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(.black)
                    }
                }
                .padding()

                Button {
                    restTime = restTime + 60
                } label: {
                    VStack {
                        ZStack {
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.orange.opacity(0.2))
                            Image(systemName: "plus")
                                .padding(20)
                                .fontWeight(.heavy)
                                .foregroundStyle(.black)
                        }
                        Text("+1 MIN")
                            .font(.footnote)
                            .fontWeight(.black)
                            .foregroundStyle(.black)
                    }
                }
                .padding()

            }

            //tertiary logic for next exercise card
            if isLastSet {
                NextExerciseCardView()
            } else {
                Spacer(minLength: 60)
            }

            Button {
                dismissSheet.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: .infinity, height: 60)
                        .foregroundStyle(.orange.opacity(0.2))
                        .padding()
                    HStack {
                        Text("Skip Rest")
                        Image(systemName: "chevron.right.2")
                    }
                    .foregroundStyle(.black)
                    .fontWeight(.bold)
                }
            }

        }
    }
}

#Preview {
    @Previewable @State var showSheet = false
    @Previewable @State var isLastSet = false
    RestCardView(dismissSheet: $showSheet, isLastSet: $isLastSet)
}
