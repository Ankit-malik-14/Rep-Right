//
//  PresetsAccordingToBodyParts.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct PresetsAccordingToBodyParts: View {
    @Environment(Presets.self) var preset
    var body: some View {
        VStack{
            HStack{
                Text("Presets")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Spacer()
                Button("See all") {
                    //
                }.buttonStyle(.automatic)
                .tint(.orange)
                .padding()
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(preset.presets) { preset in
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 165, height: 150)
                                .foregroundStyle(.background.secondary)
                            Text(preset.name)}
                    }
                }
            }.scrollIndicators(.hidden)
                .navigationTitle("Presets")
        }
    }
}

#Preview {
    PresetsAccordingToBodyParts()
        .environment(Presets())
}
