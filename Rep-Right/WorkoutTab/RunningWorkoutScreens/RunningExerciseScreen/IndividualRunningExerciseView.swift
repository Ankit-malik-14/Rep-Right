//
//  IndividualRunningExerciseView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 23/03/26.
//

//
//  IndividualRunningExerciseView.swift
//  Rep-Right
//
//  REPLACE your existing file with this.
//  Change: now takes `exercise: Exercise` and wires "AI Assistance" to LiveAssistanceView.
//

import SwiftUI

struct IndividualRunningExerciseView: View {
    var exercise: Exercise

    @State private var showAssistance = false

    var body: some View {
        DataLabels()
        Spacer()
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(maxWidth: .infinity, maxHeight: 270)
                    .foregroundStyle(.background.secondary)
                    .padding()
                    .offset(y: 25)

                VStack(alignment: .center, spacing: 15) {

                    // Exercise card
                    RoundedRectangle(cornerRadius: 30)
                        .glassEffect(.regular, in: .rect(cornerRadius: 30))
                        .frame(width: 350, height: 150)
                        .foregroundStyle(.background.secondary)
                        .overlay {
                            VStack(alignment: .leading, spacing: -6) {
                                Text(exercise.name)
                                    .font(.title2.bold())
                                    .padding()
                                HStack {
                                    VStack {
                                        Text("Set")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.secondary)
                                            .padding(5)
                                        Text("3/4")
                                            .font(.title2.bold())
                                    }.padding(.horizontal)
                                    Spacer()
                                    VStack {
                                        Text("Weight")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.secondary)
                                            .padding(5)
                                        Text("70 kg")
                                            .font(.title2.bold())
                                    }.padding(.horizontal)
                                }
                            }
                        }

                    // Control buttons
                    HStack(spacing: 10) {
                        Button { } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 100, height: 55)
                                    .foregroundStyle(.background.tertiary)
                                Text("Pause")
                                    .foregroundStyle(.orange)
                                    .font(.subheadline.bold())
                            }
                        }
                        Button { } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 100, height: 55)
                                    .foregroundStyle(.background.tertiary)
                                Text("Skip")
                                    .foregroundStyle(.orange)
                                    .font(.subheadline.bold())
                            }
                        }
                        Button { } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 105, height: 55)
                                    .foregroundStyle(.background.tertiary)
                                Text("Finish Set")
                                    .foregroundStyle(.orange)
                                    .font(.subheadline.bold())
                            }
                        }
                    }

                    // AI Assistance button
                    Button {
                        showAssistance = true
                    } label: {
                        ZStack {
                            Capsule()
                                .frame(width: 340, height: 55)
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                    .foregroundStyle(.white)
                                Text("AI Assistance")
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .tint(.orange)
                    .opacity(exercise.assistanceAvailable ? 1 : 0.4)
                    .disabled(!exercise.assistanceAvailable)
                }
            }
            .padding(.bottom)
        }

        Button { } label: {
            Text("End Session")
                .padding()
                .frame(maxWidth: .infinity)
        }
        .tint(.orange)
        .buttonStyle(.glass)
        .padding(.horizontal)
        .fullScreenCover(isPresented: $showAssistance) {
            LiveAssistanceView(exercise: exercise)
        }
    }
}

#Preview {
    IndividualRunningExerciseView(
        exercise: Exercise(
            name: "Bodyweight Squat",
            targetAreas: ["Quads", "Glutes"],
            equipments: [],
            executionSteps: ["Lower until thighs are parallel."],
            tips: ["Keep knees over toes."],
            assistanceAvailable: true,
            demoVideo: nil,
            setData: [SetData(sets: 4, reps: 15)]
        )
    )
}
