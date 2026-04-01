//
//  CustomPreset.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPreset: View {
    var preset: CustomPresetsDummyData
    var body: some View {
        VStack(spacing: 5){
            HStack{
                Text("Custom")
                    .font(.title.bold())
                Spacer()
                NavigationLink(value: ExpandedViews.customPresets){
                    Text("See all")
                }.tint(.orange)
            }.padding(.horizontal)
            ScrollView(.horizontal){
                HStack{
                    ForEach(0..<min(preset.customPresets.count, 3),id: \.self){ idx in
                        NavigationLink(value: CustomPresetsDummyData().customPresets[idx]) {
                            PresetTileViewType(preset: preset.customPresets[idx], type: .large)
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
//    @Previewable @Environment(Presets.self) var preset
    CustomPreset(preset: CustomPresetsDummyData())
        .environment(CustomPresetsDummyData())
}
