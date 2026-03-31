//
//  SchedulerCards.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-31.
//

import SwiftUI

struct SchedulerCards: View {
    var preset: Preset?
    @State var isRest = false
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .center){
                VStack(alignment: .leading){
                    Text("Monday")
                        .font(.caption).fontWeight(.heavy).foregroundStyle(isRest ? Color.secondary: .orange)
                    
                    if !isRest{
                        Text(preset?.name ?? "")
                            .font(.title2).bold()
                    }
                    else{
                        Text("Rest Day")
                            .font(.title2).bold().foregroundStyle(.secondary)
                    }
                    
                }
                Spacer()
                Toggle(isOn: $isRest){
                    Text("Rest Day")
                        .font(.headline).bold().foregroundStyle(isRest ? .primary:.secondary)
                }
                    .frame(width: 140)
            }
            if !isRest{
                if preset != nil{
                    HStack{
                        RoundedRectangle(cornerRadius: 13)
                            .frame(width: 58,height: 58)
                            .foregroundStyle(.orange)
                            .opacity(0.4).overlay{
                                Image(systemName: "dumbbell.fill").foregroundStyle(.orange)
                            }
                        VStack(alignment: .leading) {
                            HStack(alignment:.bottom ,spacing: 2){
                                Image(systemName: "flame.fill")
                                Text("\(preset!.calories) Kcal")
                                Text("•")
                                Image(systemName: "clock")
                                Text("\(preset!.estTime) mins")
                            }.font(.caption2).foregroundStyle(.secondary)
                            Text("Includes \(preset!.exercises.map(\.name).joined(separator: ", "))").font(.body).bold().lineLimit(2)
                            
                        }
                        VStack{
                            Button("Edit"){
                                
                            }.buttonStyle(.borderedProminent).tint(.orange)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).foregroundStyle(.background.secondary))
                }
                else{
                    Button{
                        
                    } label: {
                        VStack{
                            ZStack{
                                Circle()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(.background)
                                    .overlay{
                                        Image(systemName: "plus")
                                            .bold()
                                            .foregroundStyle(.orange)
                                        }
                            }
                            Text("Tap to schedule a preset")
                                .foregroundStyle(.secondary)
                        }.padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .overlay{
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(style: .init(dash: [2]))
                                    .foregroundStyle(.secondary)
                            }
                        )
                        .padding(.top)
                    }.buttonStyle(.plain)
                }
            }
            else {
                VStack{
                    Image(systemName: "zzz")
                        .font(.title)
                        .padding(.bottom,2)
                    Text("Recovery is key to growth")
                        .font(.body).bold()
                }
                .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(style: .init(dash: [2]))
                    )
                    .foregroundStyle(.secondary)
                    
            }
            
        }.padding().background(RoundedRectangle(cornerRadius: 20).foregroundStyle(.background).shadow(radius:10))
    }
}

#Preview {
    SchedulerCards(preset: nil)
}
