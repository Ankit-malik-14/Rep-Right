//
//  WorkoutPage.swift
//  RepRight
//
//  Created by Mayurakshi on 09/03/26.
//

//First Page of the app (for regular users)
import SwiftUI

struct ScheduledWorkout: View {
    var body: some View {
        ZStack{
            
            //Scheduled workout
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.background.secondary)
                .frame(width: 380, height: 300)
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.background.tertiary)
                .frame(width: 380, height: 150)
                .offset(x: 0, y: 72)
            
            //ai assistance button
            Button("AI Assistance", systemImage: "camera.viewfinder") {
                //
            }.buttonStyle(.bordered)
                .foregroundStyle(Color.orange)
                .offset(x:-97,y:-120)
        
            //starting HStack
            HStack{
                VStack{ //VStack2 start
                    Text("Today's Split")
                        .font(.title3)
                        .foregroundStyle(Color.orange)
                        .offset(x:20,y: 40)
                    Text("Back Day")
                        .font(.title)
                        .bold()
                        .offset(x:25,y: 40)
                    
                }//vStack2 ending (Titles)
                Spacer()
                VStack{//VStack3
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                        .offset(x:-5,y: 30)
                    Text("45 mins")
                        .offset(x:-5,y: 10)
                        
                }//vstack3 end (Duration)
            }//HStack ending (title + duration)
            
            HStack{//HStack2
                Text("Focus: Back & Traps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
                Spacer()
                Button {
                    //
                } label: {
                    Text("Start Workout")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.orange)
                .foregroundStyle(Color.white)
                .padding()

            }//end of hstack2 (focus and button)
            .offset(x:0,y: 100)
            
        }//end of zstack
      
    }
}

#Preview {
    ScheduledWorkout()
}
