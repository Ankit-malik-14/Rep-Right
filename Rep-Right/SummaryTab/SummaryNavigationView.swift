//
//  SummaryNavigationView.swift
//  Rep-Right
//

import SwiftUI

struct SummaryNavigationView: View {
    // UPDATED: Now uses WorkoutSummaryManager
    @Environment(WorkoutSummaryManager.self) private var data
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Quick stats header
                    // UPDATED: Use WorkoutSummaryManager metrics instead of deprecated mock properties
                    HStack(spacing: 20) {
                        let totalCals = data.weeklyCalorieChartData.reduce(0) { $0 + $1.calories }
                        quickStat(
                            icon: "flame.fill",
                            value: "\(totalCals)",
                            label: "kcal",
                            color: .orange
                        )
                        quickStat(
                            icon: "figure.run",
                            value: "\(data.activeMinutesCurrentWeek)",
                            label: "min",
                            color: .green
                        )
                        quickStat(
                            icon: "chart.line.uptrend.xyaxis",
                            value: "\(Int(data.calorieProgress * 100))%",
                            label: "goal",
                            color: .blue
                        )
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // MARK: - Value-based Navigation Links
                    
                    NavigationLink(value: SummaryRoute.calorieBreakdown) {
                        // UPDATED: Dynamic weekly calorie sum
                        let totalCals = data.weeklyCalorieChartData.reduce(0) { $0 + $1.calories }
                        routeCard(
                            icon: "flame.fill",
                            title: "Weekly Calories",
                            subtitle: "\(totalCals) kcal burned this week",
                            color: .orange
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(value: SummaryRoute.metricRing) {
                        // UPDATED: Dynamic progress reading
                        routeCard(
                            icon: "figure.run",
                            title: "Activity Metrics",
                            subtitle: "\(Int(data.calorieProgress * 100))% of weekly target reached",
                            color: .green
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .navigationTitle("Summary")
            .navigationDestination(for: SummaryRoute.self) { route in
                switch route {
                case .calorieBreakdown:
                    CalorieBreakdownView()
                case .metricRing:
                    MetricRingView()
                case .userCalorieIntake:
                    UserCalorieIntake()
                }
            }
            // Removed UserProfile navigation sync. Profile tab handles it independently.
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // UPDATED: Simply push an empty profile route or rely on the ProfileTab
                    Image(systemName: "person.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Components
    
    private func quickStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold().monospacedDigit())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func routeCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SummaryNavigationView()
        .environment(WorkoutSummaryManager())
}
