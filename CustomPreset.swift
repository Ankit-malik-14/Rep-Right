//
//  CustomPreset.swift
//  RepRightScreens
//
//  Created by Jugad on 09/03/26.
//

import SwiftUI

struct CustomPreset: View {
    var body: some View {
        VStack() {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .foregroundStyle(.orange)
                        .frame(width: 48, height: 48)
                    Image(systemName: "lightbulb")
                        .font(.title3)
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Create custom presets")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("You can create a custom workout preset as per your needs.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 14)

            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.badge.plus")
                        .font(.subheadline)
                    Text("Create Preset")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(UIColor.systemGray5))
            }
        }
        .background(Color(UIColor.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CustomPreset()
}
