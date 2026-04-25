//
//  ScheduledWorkoutCard.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct ScheduledWorkoutCard: View {
    @Environment(WeeklySchedules.self) var weeklySchedules
    @Environment(WorkoutRouter.self) private var router
    
    func focousPrinter(areas : [String])-> String{
        var result = ""
        for i in areas{
            result.append(i)
            if areas.last != i{
                result = result + ", "
            }
        }
        return result
    }
    
    var todaysSchedule: Preset? {
        let day = Calendar.current.component(.weekday, from: Date())
        let pair = weeklySchedules.schedules.first(where: {$0.key.rawValue == day} )
        if let value = pair?.value{
            return value
        }
        return nil
    }
    
    var body: some View {
        if let todaysSchedule = todaysSchedule{
            VStack{
                ZStack(alignment: .topLeading){
                    //Base rectangle -- IMAGE MASK
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.background.secondary)
                        .frame(width: .infinity, height: 255)
                        .padding()

                    
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width:.infinity, height: 255)
                            .overlay{
                                VStack(alignment: .leading){
                                    assisstanceAvailablityTag(type: .iconAndText)
                                        .padding()
                                    Spacer()
                                    UnevenRoundedRectangle(bottomLeadingRadius: 20,bottomTrailingRadius: 20)
                                        .foregroundStyle(.background.tertiary)
                                        .frame(width: .infinity, height: 120)
                                        .shadow(radius: 5)
                                        .overlay {
                                            
                                            //Vstack for info part
                                            VStack(alignment: .leading, spacing: -20){
                                                HStack{
                                                    VStack(alignment: .leading){
                                                        
                                                        Text("Today's Routine")
                                                            .foregroundStyle(.orange)
                                                            .font(.footnote).fontWeight(.heavy)
                                                        Text(todaysSchedule.name)
                                                            .font(.title3.bold())
                                                        
                                                    }
                                                    .padding()
                                                    
                                                    Spacer()
                                                    
                                                    
                                                    VStack(alignment: .trailing){
                                                        Text("Duration")
                                                            .font(.caption)
                                                            .fontWeight(.bold)
                                                        Text("\(todaysSchedule.estTime) min")
                                                            .font(.caption)
                                                            
                                                        
                                                    }
                                                    .padding()
                                                }
        
                                                HStack{
                                                    
                                                    Text(focousPrinter(areas: todaysSchedule.focousArea))
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                    Spacer()
                                                    Button {
                                                        router.push(.preWorkoutGate(todaysSchedule))
                                                    } label: {
                                                        Text("Start Workout")
                                                    }.buttonStyle(.borderedProminent)
                                                        .tint(.orange)
                                                    
                                                } // end of hstack focus area+button
                                                .padding()
                                            }
                                            
                                        }
                                }
                            }
                            .padding()
                }
            }
        }
    }
}

#Preview {
    ScheduledWorkoutCard()
        .environment(WeeklySchedules())
}
