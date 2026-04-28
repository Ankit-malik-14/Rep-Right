//
//  MetricRingView.swift
//  Rep-Right
//

import SwiftUI

struct MetricRingView: View {
    
    @Environment(WorkoutSummaryManager.self) private var data
    @Environment(UserProfileModel.self) private var profile
    @State private var animatedProgress: Double = 0

    private var activeMinutesProgress: Double {
        guard data.targetActiveMinutes > 0 else { return 0 }
        return min(Double(data.activeMinutesCurrentWeek) / Double(data.targetActiveMinutes), 1.0)
    }

    private var streakProgress: Double {
        let streakGoal = max(profile.weeklyGoalDays, 1)
        return min(Double(data.currentStreak) / Double(streakGoal), 1.0)
    }

    private var consistencyProgress: Double {
        let goalDays = max(profile.weeklyGoalDays, 1)
        return min(Double(data.activeDaysCurrentWeek) / Double(goalDays), 1.0)
    }

    private var overallProgress: Double {
        (activeMinutesProgress + streakProgress + consistencyProgress) / 3.0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                // MARK: - Custom Circular Progress
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(.quaternary, lineWidth: 24)
                    
                    // Progress arc
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            AngularGradient(
                                colors: [.orange, .red, .orange],
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 24, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    // Center label
                    VStack(spacing: 4) {
                        Text("\(Int(animatedProgress * 100))")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                        Text("percent")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 220, height: 220)
                .padding(.top, 20)
                
                VStack(spacing: 14) {
                    HStack(spacing: 14) {
                        metricCard(
                            icon: "figure.walk",
                            title: "Active Minutes",
                            value: "\(data.activeMinutesCurrentWeek)",
                            target: "\(data.targetActiveMinutes) min goal",
                            color: .green
                        )
                        
                        metricCard(
                            icon: "trophy.fill",
                            title: "Streak",
                            value: "\(data.currentStreak)",
                            target: "\(profile.weeklyGoalDays)-day goal",
                            color: .yellow
                        )
                    }

                    metricCard(
                        icon: "heart.fill",
                        title: "Consistency",
                        value: "\(Int(consistencyProgress * 100))%",
                        target: "\(data.activeDaysCurrentWeek)/\(profile.weeklyGoalDays) active days",
                        color: .red
                    )
                }
                .padding(.horizontal, 4)
            }
            .padding()
        }
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            animateRing(to: overallProgress)
        }
        .onChange(of: overallProgress) { _, newValue in
            animateRing(to: newValue)
        }
    }
    
    // MARK: - Metric Card Component

    private func animateRing(to progress: Double) {
        withAnimation(.spring(duration: 1.0, bounce: 0.2)) {
            animatedProgress = progress
        }
    }
    
    private func metricCard(icon: String, title: String, value: String, target: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2.bold().monospacedDigit())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.bold())
                Text(target)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        MetricRingView()
            .environment(WorkoutSummaryManager())
            .environment(UserProfileModel())
    }
}
