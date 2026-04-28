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
            VStack(alignment: .leading) {
                        // Text Content
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Create custom presets")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("You can create a custom workout preset as per your needs.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 12)
                        // Action Button
                        Button(action: {
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
                            .background(.black.opacity(0.06))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                
        }
        else{
            VStack(spacing: 5){
                HStack{
                    NavigationLink(value: WorkoutRoute.customPresetsList){
                        HStack{
                            Text("Custom Presets")
                                .foregroundStyle(.black)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .tint(.orange)
                                .padding(.top,4)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                ScrollView(.horizontal){
                    HStack{
                        ForEach(0..<min(preset.customPresets.count, 3),id: \.self){ idx in
                            NavigationLink(value: WorkoutRoute.presetDetail(preset.customPresets[idx])) {
                                PresetTileViewType(preset: preset.customPresets[idx], type: .large)
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
//    @Previewable @Environment(Presets.self) var preset
    CustomPreset(preset: CustomPresetsDummyData())
        .environment(CustomPresetsDummyData())
}
