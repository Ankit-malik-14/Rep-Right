//
//  StatsCardView.swift
//  PresettFlow
//
//  Created by Jugad on 17/03/26.
//

import SwiftUI

struct StatsCardView: View {
    @State var showScheduler: Bool = false
    var preset: Preset? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            // Using Grid for perfect 2x2 alignment
            Grid(alignment: .leading, horizontalSpacing: 80, verticalSpacing: 24) {
                GridRow {
                    StatItemView(icon: "flame.fill", title: "Calories", value: preset.map { "\($0.calories) kcal" } ?? "450 kcal")
                    StatItemView(icon: "clock", title: "Time", value: preset.map { "\($0.estTime) mins" } ?? "45 mins")
                }
                GridRow {
                    StatItemView(icon: "dumbbell.fill", title: "Equipment", value: preset?.equipments.first ?? "Dumbbells")
                    StatItemView(icon: "figure.walk", title: "Target", value: preset?.focousArea.first ?? "Back")
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            if !(preset?.isWarmpUp ?? false) {
                Divider()
                    .frame(width: 300)
                
                Button(action: {
                    showScheduler.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text("Schedule workout")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }
                .sheet(isPresented: $showScheduler, content: {
                    SchedulerView(contextPreset: preset)
                })
                .padding(.bottom, 16)
            } else {
                Spacer().frame(height: 16)
            }
        }
        //.frame(width: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 10)
    }
}

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
        .environment(WeeklySchedules())
        
}
