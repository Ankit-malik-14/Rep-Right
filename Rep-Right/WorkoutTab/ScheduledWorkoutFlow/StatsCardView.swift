//
//  StatsCardView.swift
//  PresettFlow
//
//  Created by Jugad on 17/03/26.
//

import SwiftUI

/// Stats Grid View showing Calories, Time, Equipment, and Target
struct StatsCardView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Using Grid for perfect 2x2 alignment
            Grid(alignment: .leading, horizontalSpacing: 80, verticalSpacing: 24) {
                GridRow {
                    StatItemView(icon: "flame.fill", title: "Calories", value: "450 kcal")
                    StatItemView(icon: "clock", title: "Time", value: "45 mins")
                }
                GridRow {
                    StatItemView(icon: "dumbbell.fill", title: "Equipment", value: "Dumbbells")
                    StatItemView(icon: "figure.walk", title: "Target", value: "Back")
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            Divider()
                .frame(width: 300)
            
            Button(action: {
                print("Schedule workout tapped")
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text("Schedule workout")
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
            .padding(.bottom, 16)
        }
        //.frame(width: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 10)
    }
}

/// Helper view for individual stat items in the Grid
struct StatItemView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.orange)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }
}


#Preview {
    StatsCardView()
}
