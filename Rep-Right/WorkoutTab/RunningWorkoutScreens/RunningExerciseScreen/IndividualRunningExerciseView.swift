//
//  IndividualRunningExerciseView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 23/03/26.
//

import SwiftUI

struct IndividualRunningExerciseView: View {
    var body: some View {
        DataLabels()
        Spacer()
        VStack{
            //background Card
            ZStack{
                //base rectangle
                RoundedRectangle(cornerRadius: 20)
                    .frame(maxWidth: .infinity,maxHeight: 270)
                    .foregroundStyle(.background.secondary)
                    .padding()
                    .offset(y: 25)
                    
                
                //VStack for buttons and card
                VStack(alignment: .center,spacing: 15){
                    
                    //Exercise card
                   
                        //exercise card base rectangle
                        RoundedRectangle(cornerRadius: 30)
                        .glassEffect(.regular, in: .rect(cornerRadius: 30))
                            .frame(width: 350, height: 150)
                            .foregroundStyle(.background.secondary)
                            .overlay(content: {
                                //vstack for exercise name, set and weight
                                VStack(alignment: .leading, spacing: -6){
                                    Text("Deadlift")
                                        .font(.title2.bold())
                                        .padding()
                                    //hstack for set and weight
                                    HStack{
                                        //VStack for set and set number
                                        VStack{
                                            Text("Set")
                                                .font(.subheadline.bold())
                                                .foregroundStyle(.secondary)
                                                .padding(5)
                                            Text("3/4")
                                                .font(.title2.bold())
                                        }.padding(.horizontal)
                                        
                                        Spacer()
                                        
                                        //vstack weight
                                        VStack{
                                            Text("Weight")
                                                .font(.subheadline.bold())
                                                .foregroundStyle(.secondary)
                                                .padding(5)
                                            Text("70 kg")
                                                .font(.title2.bold())
                                        }.padding(.horizontal)
                                    }
                                }
                            })
                    // play pause and finish set button
                    HStack(spacing: 10){
                        
                        //PAUSE BUTTON
                        Button {
                            //
                        } label: {
                            ZStack{ // pause button
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 100, height: 55)
                                    .foregroundStyle(.background.tertiary)
                                HStack{ //pause + image
                                    Image(systemName: "pause.fill")
                                        .foregroundStyle(.orange)
                                    Text("Pause")
                                        .foregroundStyle(.orange)
                                        .font(.subheadline.bold())
                                }
                            }
                        }
                        //SKIP
                        Button {
                            //
                        } label: {
                            ZStack{ // pause button
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 100, height: 55)
                                    .foregroundStyle(.background.tertiary)
                                HStack{ //pause + image
                                    Image(systemName: "chevron.right.2")
                                        .bold()
                                        .foregroundStyle(.orange)
                                    Text("Skip")
                                        .foregroundStyle(.orange)
                                        .font(.subheadline.bold())
                                }
                            }
                        }
                        
                        //Finish Set
                        Button {
                            // Finish set
                        } label: {
                            ZStack{ // pause button
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 105, height: 55)
                                    .foregroundStyle(.background.tertiary)
                                HStack{ //pause + image
                                    Image(systemName: "checkmark")
                                        .bold()
                                        .foregroundStyle(.orange)
                                    Text("Finish Set")
                                        .foregroundStyle(.orange)
                                        .font(.subheadline.bold())
                                    
                                }
                            }
                        }
                        
                    }
//                    .padding()
                    
                    //Ai assistance button
                    Button {
                        // go to posture detection
                    } label: {
                        ZStack{
                            Capsule()
                                .frame(width: 340, height: 55)
                            //assistance text
                            HStack{
                                Image(systemName: "camera.viewfinder")
                                    .foregroundStyle(.white)
                                Text("AI Assistance")
                                    .foregroundStyle(.white)
                            }
                        }
                    }.tint(.orange)

                }
//                .frame(maxHeight:200)
            }
            .padding(.bottom)
            //end session button
            

        }
        Button {
            //end session
        } label: {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 340, height: 55)
                Text("End Session")
                    .foregroundStyle(.white)
            }
        }.tint(.orange)
    }
}
#Preview {
    IndividualRunningExerciseView()
        
}

