//
//  ScheduledWorkoutCard.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct ScheduledWorkoutCard: View {
    @Environment(WorkoutHomeViewModel.self) private var viewModel
    @Environment(WorkoutRouter.self) private var router
    
    private func focusPrinter(areas: [String]) -> String {
        areas.joined(separator: ", ")
    }
    
    var body: some View {
        if let todaysSchedule = viewModel.todaySchedule {
            VStack {
                ZStack(alignment: .topLeading) {
                    Group {
                        if let imageName = todaysSchedule.image {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                        } else {
                            RoundedRectangle(cornerRadius: AppCardMetrics.cornerRadius)
                                .fill(Color(.tertiarySystemFill))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 255)
                    .clipShape(RoundedRectangle(cornerRadius: AppCardMetrics.cornerRadius, style: .continuous))
                    
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.2), .black.opacity(0.72)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppCardMetrics.cornerRadius, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        assisstanceAvailablityTag(type: .iconAndText)
                            .padding(16)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Today's Routine")
                                        .foregroundStyle(.orange)
                                        .font(.footnote.weight(.heavy))
                                    Text(todaysSchedule.name)
                                        .font(.title3.bold())
                                        .foregroundStyle(.white)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Duration")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white.opacity(0.8))
                                    Text("\(todaysSchedule.estTime) min")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            HStack(alignment: .bottom, spacing: 12) {
                                Text(focusPrinter(areas: todaysSchedule.focousArea))
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.84))
                                    .lineLimit(2)
                                
                                Spacer(minLength: 12)
                                
                                Button {
                                    router.push(.activeWorkout(todaysSchedule))
                                } label: {
                                    Text("Start Workout")
                                        .font(.headline)
                                        .padding(.horizontal, 8)
                                }
                                .buttonStyle(AppPrimaryButtonStyle())
                                .frame(maxWidth: 150)
                            }
                        }
                        .padding(16)
                        .background(.ultraThinMaterial, in: UnevenRoundedRectangle(bottomLeadingRadius: AppCardMetrics.cornerRadius, bottomTrailingRadius: AppCardMetrics.cornerRadius))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 255)
                .appCardStyle()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ScheduledWorkoutCard()
        .environment(WeeklySchedules())
        .environment(WorkoutRouter())
}
