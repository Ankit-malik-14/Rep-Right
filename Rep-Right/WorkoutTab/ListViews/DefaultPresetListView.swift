//
//  DefaultPresetListView.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-25.
//

import SwiftUI

struct DefaultPresetListView: View {
    var presets: Presets
    var body: some View {
        ScrollView{
            VStack{
                ForEach(presets.presets){ preset in
                    NavigationLink(value: preset) {
                        PresetTileViewType(preset: preset, type: .large)
                            .background(RoundedRectangle(cornerRadius: 16).foregroundStyle(.background.secondary)).padding(.horizontal)
//                        HStack(alignment: .center){
//                            //Image Placeholder
//                            RoundedRectangle(cornerRadius: 16)
//                                .frame(width: 67, height: 64)
//                                .foregroundStyle(.background.secondary)
//                                .padding(6)
//                            VStack(alignment: .leading){
//                                Text(preset.name)
//                                    .font(.headline)
//                                HStack{
//                                    Text(arrayToString(arrayOfStrings: preset.focousArea))
//                                    
//                                    Text("•")
//                                    Text("\(preset.exercises.count) Exercises")
//                                }.font(.footnote).foregroundStyle(.secondary)
//                            }
//                            Spacer()
//                        }.background(.background.secondary,in: RoundedRectangle(cornerRadius: 20)).padding(.horizontal)
                    }.buttonStyle(.plain)
                    
                }
            }
            
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(role: .destructive){
                        //
                    } label: {
                        Image(systemName: "trash")
                    }
                    Button{
                        //
                    }
                    label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }.navigationTitle("Presets")
        }.padding(.vertical)
    }
}

#Preview {
    NavigationStack{
        DefaultPresetListView(presets: Presets())
            .environment(Presets())
    }
}


