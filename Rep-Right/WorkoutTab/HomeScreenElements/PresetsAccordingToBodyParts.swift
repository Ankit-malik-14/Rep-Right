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
        VStack(spacing: 5){
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
//                .padding()
            }.padding(.horizontal)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(preset.presets) { preset in
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 165, height: 150)
                                .foregroundStyle(.background.secondary)
                            Text(preset.name)}
                    }
                }.padding(.horizontal)
            }
            .scrollIndicators(.hidden)
//                .navigationTitle("Presets")
        }
    }
}

#Preview {
    @Previewable @Environment(Presets.self) var preset
    PresetsAccordingToBodyParts()
        .environment(Presets())
}
