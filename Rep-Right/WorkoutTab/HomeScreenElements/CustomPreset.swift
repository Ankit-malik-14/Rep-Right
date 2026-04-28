//
//  CustomPreset.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPreset: View {
    var preset: CustomPresetsDummyData
    @State var showScreen = false
    var body: some View {
        if(preset.customPresets.count == 0){
            VStack(alignment: .leading, spacing: 0) {
                        // Text Content
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Create custom presets")
                                .font(.title3)
                                .fontWeight(.bold)
                                //.foregroundColor()
                            
                            Text("You can create a custom workout preset as per your needs.")
                                .font(.caption)
                                //.foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 12)
                        // Action Button
                        Button(action: {
                            // Add your action here
                            showScreen.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.footnote)
                                
                                Text("Create Preset")
                                    .font(.footnote)
                            }
                            .popover(isPresented: $showScreen, content: {
                                CustomPresetAdditionView(isPresented: $showScreen)
                            })
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(.black.opacity(0.4))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
            .background(.gray.opacity(0.2))
                    .cornerRadius(16)
                
        }
        else{
            VStack(spacing: 5){
                HStack{
                    Text("Custom")
                        .font(.title.bold())
                    Spacer()
                    NavigationLink(value: WorkoutRoute.customPresetsList){
                        Text(preset.customPresets.count == 0 ? "" : "See all")
                    }
                    .tint(.orange)
                }
                .padding(.horizontal)
                ScrollView(.horizontal){
                    HStack{
                        ForEach(0..<min(preset.customPresets.count, 3),id: \.self){ idx in
                            NavigationLink(value: WorkoutRoute.presetDetail(preset.customPresets[idx])) {
                                PresetTileViewType(preset: preset.customPresets[idx], type: .large)
                            }.buttonStyle(.plain)
                        }
                    }.padding(.horizontal)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

#Preview {
//    @Previewable @Environment(Presets.self) var preset
    CustomPreset(preset: CustomPresetsDummyData())
        .environment(CustomPresetsDummyData())
}
