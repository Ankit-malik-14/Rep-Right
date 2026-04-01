//
//  PresetSelectionView.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-31.
//

import SwiftUI

struct PresetSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var weekday : Weekday
    @Environment(WeeklySchedules.self) var weeklySchedules
    @Environment(Presets.self) var presets
    @State var searchFieldText = ""
    @State var selectedPreset: Preset?
    var body: some View {
        NavigationStack{
            ScrollView{
                if !searchFieldText.isEmpty{
                    ForEach(presets.presets.filter({$0.name.lowercased().contains(searchFieldText.lowercased())})){ preset in
                        Button {
                            if selectedPreset == nil{
                                selectedPreset = preset
                            }
                            else if selectedPreset == preset {
                                selectedPreset = nil
                            }
                            else if selectedPreset != preset{
                                selectedPreset = preset
                            }
                        } label: {
                            PresetTileViewType(preset: preset, type: .small)
                                .background(selectedPreset == preset ? .orange.opacity(0.5) : .gray.opacity(0.4),in: RoundedRectangle(cornerRadius: 20)).padding(.horizontal)
                        }.buttonStyle(.plain)
                    }
                    
                }
                else{
                    ForEach(presets.presets){ preset in
                        Button{
                            if selectedPreset == nil{
                                selectedPreset = preset
                            }
                            else if selectedPreset == preset{
                                selectedPreset = nil
                            }
                            else if selectedPreset != preset{
                                selectedPreset = preset
                            }
                        } label: {
                            PresetTileViewType(preset: preset, type: .small)
                                .background(selectedPreset == preset ? .orange.opacity(0.5) : .gray.opacity(0.4),in: RoundedRectangle(cornerRadius: 20)).padding(.horizontal)
                        }.buttonStyle(.plain)
                        
                    }
                }
                
            }.searchable(text: $searchFieldText, placement: .navigationBarDrawer, prompt: "Name of preset")
                .toolbar(content: {
                    ToolbarItem{
                        Button{dismiss()} label: {
                            Image(systemName: "xmark")
                        }
                    }
                })
                .navigationTitle("Select Preset")
            if selectedPreset != nil{
                Button{
                    weeklySchedules.schedules.updateValue(selectedPreset!, forKey: weekday)
                    selectedPreset = nil
                    dismiss()
                }label: {
                    Text("Done")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.orange, in: RoundedRectangle(cornerRadius: 13))
                        .padding()
                }.buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack{
        PresetSelectionView(weekday: .monday)
            .environment(Presets())
            .environment(WeeklySchedules())
    }
}
