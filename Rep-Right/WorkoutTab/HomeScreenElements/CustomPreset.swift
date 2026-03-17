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
        VStack{
            HStack{
                Text("Custom")
                    .font(.largeTitle.bold())
                Spacer()
                Button("See all") {
                    //
                }.buttonStyle(.borderless)
                    .tint(.orange)
            }.padding()
            
            ScrollView(.horizontal){
                HStack{
                    ForEach(preset.presets){ preset in
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.background.secondary)
                                .frame(width: 180,height: 160)
                            Text(preset.name)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    //@Previewable @Environment(Presets.self) var presets
    CustomPreset()
        .environment(Presets())
}
