//
//  ScheduledWorkoutCard.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct ScheduledWorkoutCard: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("Workouts")
                .font(.largeTitle)
                .bold()
                .padding()
            ZStack(alignment: .bottomTrailing){
                

                //Base rectangle
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.background.secondary)
                    .frame(width: .infinity, height: 255)
                    .padding()
                        
                // for details overlay
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.background.tertiary)
                    .frame(width: .infinity, height: 120)
                    .shadow(radius: 5)
                    .overlay {

                            //Vstack for info part
                            VStack(alignment: .leading, spacing: -20){
                                //HStack for routine and duration
                                HStack{
                                    VStack(alignment: .leading){ //Today's routine + reps
                                        Text("Today's Routine")
                                            .foregroundStyle(.orange)
                                            .font(.title3)
                                        Text("Back Day")
                                            .font(.title.bold())
                                    } // end of vstack today's routine+reps
                                    .padding()
                                    
                                    Spacer()
                                    
                                    //vstack for duration + time
                                    VStack(alignment: .center){
                                        Text("Duration")
                                            .font(.caption)
                                        Text("45 mins")
                                            .font(.title)
                                    }//end of vstack duration+time
                                    .padding()
                                } //end of hstack1
                                
                                
                                //HStack 2 for focus area and Button
                                HStack{
                                    Text("Focus: back and traps")
                                        .font(.callout)
                                    
                                    Spacer()
                                    Button {
                                        //
                                    } label: {
                                        Text("Start Workout")
                                    }.buttonStyle(.borderedProminent)
                                        .tint(.orange)
                                    
                                } // end of hstack focus area+button
                                .padding()
                            }

                    }.padding()
                    }
        }
    }
}

#Preview {
    ScheduledWorkoutCard()
}
