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
                Text("Presets")
                    .font(.title)
                    .bold()

                Spacer()
                NavigationLink(value: ExpandedViews.defaultPresets) {
                    Text("See all")
                }.tint(.orange)
            }.padding(.horizontal)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<min(preset.presets.count, 3), id: \.self) { idx in
                        NavigationLink(value: Presets().presets[idx]) {
                            PresetTileViewType(preset: preset.presets[idx], type: .large)
                        }.buttonStyle(.plain)
                        
                    }
                }.padding(.horizontal)
            }
            .scrollIndicators(.hidden)
//                .navigationTitle("Presets")
        }
    }
}


 


#Preview {
//    @Previewable @Environment(Presets.self) var preset
    DefaultPresets(preset: Presets())
        .environment(Presets())
}
