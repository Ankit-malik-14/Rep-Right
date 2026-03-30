//
//  CustomPreset.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPreset: View {
    @Environment(Presets.self) var preset
    
    var body: some View {
        VStack(spacing: 5){
            HStack{
                Text("Custom")
                    .font(.largeTitle.bold())
                Spacer()
                Button("See all") {
                    //
                }.buttonStyle(.borderless)
                    .tint(.orange)
            }.padding(.horizontal)
            ScrollView(.horizontal){
                HStack{
                    ForEach(0..<min(preset.presets.count, 3),id: \.self){ idx in
                        
                        PresetTileViewType(preset: preset.presets[idx], type: .large)
                        
                    }
                }.padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
//    @Previewable @Environment(Presets.self) var preset
    CustomPreset()
        .environment(Presets())
}
