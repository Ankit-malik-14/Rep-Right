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

#Preview {
    ScheduledWorkout()
}
