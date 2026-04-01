//
//  RunningWorkoutInfo.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 19/03/26.
//

import SwiftUI

struct RunningWorkoutInfo: View {
    var body: some View {
        Grid(alignment: .center, horizontalSpacing: 20, verticalSpacing: 12) {
            // Header row
            GridRow {
                Text("Set")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
                Text("Weight")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
                Text("Reps")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
            }
            Divider()
            
            // 1st set
            GridRow {
                Text("1")
                    .font(.title3.bold())
                    .padding()
                Text("80 kg")
                    .font(.title3.bold())
                    .padding()
                Text("8")
                    .font(.title3.bold())
                    .padding()
            }

            // 2nd set
            GridRow {
                Text("2")
                    .font(.title3.bold())
                    .padding()
                Text("80 kg")
                    .padding()
                    .font(.title3.bold())
                Text("8")
                    .font(.title3.bold())
                    .padding()
            }

            // 3rd set
            GridRow {
                Text("3")
                    .font(.title3.bold())
                    .padding()
                Text("80 kg")
                    .font(.title3.bold())
                    .padding()
                Text("8")
                    .font(.title3.bold())
                    .padding()
            }
            
            //button for add set
            Button {
                //
            } label: {
                ZStack(){
                    RoundedRectangle(cornerRadius: 8)
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .foregroundStyle(.background.secondary)
                        
                    HStack{
                        Image(systemName: "plus")
                            .font(.title)
                        Text("Add Set")
                    }.foregroundStyle(.orange)
                }.padding(.horizontal)
                    .padding(.top, 20)
            }
            
            // Controls (Pause, Skip, Finish) in a single horizontal row
            GridRow {
                HStack(spacing: 12) {
                    Button {
                        //
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                .foregroundStyle(.background.secondary)
                                .padding()
                            HStack{
                                Image(systemName: "pause")
                                    .font(.title)
                                Text("Pause")
                            }.padding()
                            .foregroundStyle(.orange)
                        }
                    }
//                    .frame(maxWidth: .infinity)

                    Button {
                        //
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                .foregroundStyle(.background.secondary)
                                .padding()
                            HStack{
                                Image(systemName: "chevron.right.2")
                                    .font(.title)
                                Text("Skip")
                            }
                            .foregroundStyle(.orange)
                        }
                    }
//                    .frame(maxWidth: .infinity)

                    Button {
                        //
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                .foregroundStyle(.background.secondary)
                                .padding()
                            Text("Pause")
                                .foregroundStyle(.orange)
                        }
                    }
//                    .frame(maxWidth: .infinity)
                }
                .gridCellColumns(3)
            }
            
            //button for use assistance
            Button {
                //
            } label: {
                HStack{
                    Image(systemName: "camera.viewfinder")
                    Text("Use Assistance")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

        }.padding()
        
    }
}

#Preview {
    RunningWorkoutInfo()
}
