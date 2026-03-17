//
//  ExercisesView.swift
//  Rep-Right
//
//  Created by GU on 17/03/26.
//

import SwiftUI

struct ExercisesView: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    ZStack{
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 100,height: 100)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 180)
                            .padding(.horizontal)
                    }
                    HStack {
                        Text("Squat")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        HStack {
                            //Button If Ai Assistance is Available
                            Button(action: {}) {
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "camera.fill")
                                        .font(.caption)
                                    
                                    Text("AI Assistance")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        
                        HStack(alignment: .top) {
                            Text("Focus Area :")
                                .fontWeight(.semibold)
                                .frame(width: 110, alignment: .leading)
                            
                            Text("Quadriceps, Glutes, Hamstrings, Lower Back, Core")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Text("Equipment :")
                                .fontWeight(.semibold)
                                .frame(width: 110, alignment: .leading)
                            
                            Text("Barbell")
                                .font(.subheadline)
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    Text("Execution")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top){
                            Text("1.")
                                .fontWeight(.semibold)
                                //.frame(width: 110, alignment: .leading)
                            Text("Lower your body by bending knees.")
                        }
                        HStack(alignment: .top){
                            Text("2.")
                                .fontWeight(.semibold)
                            Text("Return up by pushing through heels.")
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Tips")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top){
                            Text("1.")
                                .fontWeight(.semibold)
                            Text("Keep your knees in line with your toes throughout the movement.")
                        }
                        HStack(alignment: .top){
                            Text("2.")
                                .fontWeight(.semibold)
                            Text("Engage your core to maintain balance and protect your lower back.")
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    
                    Spacer(minLength: 20)
                    
                    HStack(spacing: 12) {
                        
                        Button(action: {
                            
                        }) {
                            Text("Done")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(25)
                        }
                        
                        Button(action: {
                            
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Try Workout")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        
                    }
                    .padding()
                    
                }
            }
        }
        .background(Color.white)
    }
}
#Preview {
    ExercisesView()
}

