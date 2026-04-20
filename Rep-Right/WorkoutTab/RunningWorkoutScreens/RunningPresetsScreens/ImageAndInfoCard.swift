//
//  ImageAndInfoCard.swift
//  Rep-Right
//

import SwiftUI

struct ImageAndInfoCard: View {
    var exercise: Exercise?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Background image area
            RoundedRectangle(cornerRadius: 35)
                .frame(maxWidth: .infinity, maxHeight: 250)
                .padding(.horizontal)
                .foregroundStyle(.background.secondary)
            
            // Info card with embedded content
            RoundedRectangle(cornerRadius: 35)
                .frame(maxHeight: 128)
                .shadow(radius: 10)
                .foregroundStyle(.background.tertiary)
                .overlay(
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise?.name ?? "No Exercise")
                            .font(.title)
                            .bold()
                        HStack {
                            // Target
                            VStack(alignment: .leading) {
                                Text("Target")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                Text(exercise?.targetAreas.first ?? "--")
                                    .font(.title3.bold())
                                    .lineLimit(1)
                            }

                            Spacer()

                            // Equipment
                            VStack(alignment: .trailing) {
                                Text("Equipment")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                Text(exercise?.equipments.first ?? "Bodyweight")
                                    .font(.title3.bold())
                                    .lineLimit(1)
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
