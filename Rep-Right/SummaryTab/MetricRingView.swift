//
//  MetricRingView.swift
//  Rep-Right
//

import SwiftUI

struct MetricRingView: View {
    // UPDATED: Now uses WorkoutSummaryManager
    @Environment(WorkoutSummaryManager.self) private var data
    @State private var animatedProgress: Double = 0
    
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
                
                // MARK: - Metric Cards
                LazyVGrid(columns: [.init(), .init()], spacing: 14) {
                    // UPDATED: metrics updated for WorkoutSummaryManager
                    metricCard(
                        icon: "figure.walk",
                        title: "Active Minutes",
                        value: "\(data.activeMinutesCurrentWeek)",
                        target: "\(data.targetActiveMinutes) min goal",
                        color: .green
                    )
                    
                    let totalCals = data.weeklyCalorieChartData.reduce(0) { $0 + $1.calories }
                    metricCard(
                        icon: "flame.fill",
                        title: "Calories",
                        value: "\(totalCals)",
                        target: "\(Int(data.dailyCalorieGoal * 7)) kcal goal",
                        color: .orange
                    )
                    
                    let targetDays = data.weeklyCalorieChartData.filter { Double($0.calories) >= data.dailyCalorieGoal }.count
                    metricCard(
                        icon: "trophy.fill",
                        title: "Streak",
                        value: "\(targetDays)",
                        target: "days on target",
                        color: .yellow
                    )
                    metricCard(
                        icon: "heart.fill",
                        title: "Progress",
                        value: "\(Int(data.calorieProgress * 100))%",
                        target: "of weekly goal",
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
            withAnimation(.spring(duration: 1.0, bounce: 0.2)) {
                // UPDATED: Bind to dynamic calorieProgress
                animatedProgress = data.calorieProgress
            }
        }
    }
    
    // MARK: - Metric Card Component
    
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
    }
}
