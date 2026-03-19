//
//  ScheduledWorkoutCard.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct ScheduledWorkoutCard: View {
    @Environment(Presets.self) var preset
    var body: some View {
        VStack(alignment: .leading){
            ZStack(alignment: .bottomTrailing){
                

                //Base rectangle -- IMAGE MASK
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.background.secondary)
                    .frame(width: .infinity, height: 255)
                    .padding()
                        
                // for details overlay
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.background.tertiary)
                    .frame(width: .infinity, height: 140)
                    .shadow(radius: 5)
                    .overlay {

                            //Vstack for info part
                            VStack(alignment: .leading, spacing: -20){
                                //HStack for routine and duration
                                HStack{
                                    VStack(alignment: .leading){ //Today's routine + reps
                
                                        Text("Today's Routine") //hardcoded
                                            .foregroundStyle(.orange)
                                            .font(.footnote).fontWeight(.heavy)
                                        Text("\(preset.presets[0].name)")
                                            .font(.title.bold())
                                    } // end of vstack today's routine+reps
                                    .padding()
                                    
                                    Spacer()
                                    
                                    //vstack for duration + time
                                    VStack(alignment: .trailing){
                                        Text("Duration")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                        Text("\(preset.presets[0].estTime) mins")
                                            .font(.title)
                                    }//end of vstack duration+time
                                    .padding()
                                } //end of hstack1
                                
                                
                                //HStack 2 for focus area and Button
                                HStack{
                                    Text("Focus Area: \(preset.presets[0].focousArea)")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    
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
        .environment(Presets())
}
