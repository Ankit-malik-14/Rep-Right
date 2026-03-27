//
//  DefaultPresets.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct DefaultPresets: View {
    @Environment(Presets.self) var preset
    var body: some View {
        VStack(spacing: 5){
            HStack{
                Text("Presets")
                    .font(.largeTitle)
                    .bold()

                Spacer()
                NavigationLink(value: Presets().presets) {
                    Text("See all")
                }.tint(.orange)
            }.padding(.horizontal)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<min(preset.presets.count, 3), id: \.self) { idx in
                        
                        PresetTileViewType(preset: preset.presets[idx], type: .large)
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
    DefaultPresets()
        .environment(Presets())
}
