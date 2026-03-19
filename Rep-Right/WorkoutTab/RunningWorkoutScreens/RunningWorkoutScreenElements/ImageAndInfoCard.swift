//
//  ImageAndInfoCard.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 19/03/26.
//

import SwiftUI

struct ImageAndInfoCard: View {
    var body: some View {
        @Environment(Presets.self) var preset
        ZStack(alignment: .bottom) {
            
            // Background image area
            RoundedRectangle(cornerRadius: 35)
                .frame(maxWidth: .infinity, maxHeight: 280)
                .padding(.horizontal)

            // Info card with embedded content
            RoundedRectangle(cornerRadius: 35)
                .glassEffect(.regular,in: .rect(cornerRadius: 35))
                .frame(maxHeight: 150)
                
                .foregroundStyle(.background.secondary)
                .overlay(
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(preset.presets[0].name)")
                            .font(.largeTitle)
                            .bold()

                        HStack {
                            // Sets
                            VStack(alignment: .leading) {
                                Text("Sets")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                Text("3/4")
                                    .font(.title.bold())
                            }

                            Spacer()

                            // Weight
                            VStack(alignment: .trailing) {
                                Text("Weight")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                Text("60 kg")
                                    .font(.title.bold())
                            }
                        }
                    }
                    .padding(16),
                    alignment: .bottomLeading
                )
                .padding(.horizontal)
                
        }
    }
}

#Preview {
    ImageAndInfoCard()
        .environment(Presets())
}
