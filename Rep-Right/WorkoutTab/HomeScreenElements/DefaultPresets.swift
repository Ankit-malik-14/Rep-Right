//
//  DefaultPresets.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct DefaultPresets: View {
    var preset: Presets
    var body: some View {
        VStack(spacing: 5){
            HStack{
                NavigationLink(value: WorkoutRoute.defaultPresetsList) {
                    HStack{
                        Text("Presets")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color(.label))
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal) {
//                HStack {
//                    ForEach(0..<min(preset.presets.count, 3), id: \.self) { idx in
//                        NavigationLink(value: ClickedPresetDestination.presetInfo) {
//                            PresetTileViewType(preset: preset.presets[idx], type: .large)
//                        }.buttonStyle(.plain)
//                        .navigationDestination(for: ClickedPresetDestination.self) { type in
//                            if type == ClickedPresetDestination.presetInfo {
//                                WorkoutDetailView(preset: preset.presets[idx])
//                            }
//                        }
//                        
//                    }
//                }.padding(.horizontal)
                HStack {
                    ForEach(0..<min(preset.presets.count, 3), id: \.self) { idx in
                        NavigationLink(value: WorkoutRoute.presetDetail(preset.presets[idx])) {
                            PresetTileViewType(preset: preset.presets[idx], type: .large)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                
            }
            .scrollIndicators(.hidden)
//                .navigationTitle("Presets")
        }
    }
}


 


#Preview {
//    @Previewable @Environment(Presets.self) var preset
    NavigationStack{
        DefaultPresets(preset: Presets())
            .environment(Presets())
    }
}
