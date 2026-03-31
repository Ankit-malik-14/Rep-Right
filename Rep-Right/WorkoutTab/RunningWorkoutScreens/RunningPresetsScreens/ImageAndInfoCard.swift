//
//  ImageAndInfoCard.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 19/03/26.
//

import SwiftUI

struct ImageAndInfoCard: View {
    @Environment(Presets.self) var preset
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Background image area
            RoundedRectangle(cornerRadius: 35)
                .frame(maxWidth: .infinity, maxHeight: 250)
                .padding(.horizontal)
                .foregroundStyle(.background.secondary)

            // Info card with embedded content
            RoundedRectangle(cornerRadius: 35)
//                .glassEffect(.regular,in: .rect(cornerRadius: 35))
                .frame(maxHeight: 128)
                .shadow(radius: 10)
                .foregroundStyle(.background.tertiary)
                .overlay(
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(preset.presets[0].name)")
                            .font(.title)
                            .bold()

                        HStack {
                            // Sets
                            VStack(alignment: .leading) {
                                Text("Sets")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                Text("3/4")
                                    .font(.title2.bold())
                            }

                            Spacer()

                            // Weight
                            VStack(alignment: .trailing) {
                                Text("Weight")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                Text("60 kg")
                                    .font(.title2.bold())
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
