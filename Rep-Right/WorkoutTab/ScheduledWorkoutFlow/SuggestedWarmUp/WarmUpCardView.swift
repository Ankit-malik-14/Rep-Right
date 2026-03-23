//
//  WarmupCardView.swift
//  PresettFlow
//
//  Created by Jugad on 17/03/26.
//

import SwiftUI


struct WarmUpCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.black)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recommended Warm Up")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Do some mobility drills before jumping into the action for a safe and effective session")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            NavigationLink(value: Route.warmup) {
                Text("Start Warmup")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    WarmUpCardView()
}
