//
//  CalorieBreakdownView.swift
//  Rep-Right
//

import SwiftUI
import Charts

struct CalorieBreakdownView: View, Hashable {
    // UPDATED: Use WorkoutSummaryManager
    @Environment(WorkoutSummaryManager.self) private var data
    
    static func == (lhs: CalorieBreakdownView, rhs: CalorieBreakdownView) -> Bool {
            // Since there are no initialized properties (only State/Environment),
            // all instances of this view are structurally identical.
            return true
        }
        
    func hash(into hasher: inout Hasher) {
        // Hash a constant or the type itself so the hash value is consistent
        hasher.combine(String(describing: Self.self))
    }
    
    private var totalCalories: Double {
        data.weeklyCalorieChartData.reduce(0.0) { $0 + Double($1.calories) }
    }
    
    // UPDATED: Safe average calculation
    private var averageCalories: Double {
        let count = data.weeklyCalorieChartData.count
        return count > 0 ? totalCalories / Double(count) : 0
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Summary Strip
                HStack(spacing: 0) {
                    statPill(label: "Total", value: "\(Int(totalCalories))", unit: "kcal")
                    Divider().frame(height: 32)
                    statPill(label: "Average", value: "\(Int(averageCalories))", unit: "kcal")
                    Divider().frame(height: 32)
                    // UPDATED: Use dailyCalorieGoal
                    statPill(label: "Target", value: "\(Int(data.dailyCalorieGoal))", unit: "kcal")
                }
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                
                // MARK: - Bar Chart (Apple Fitness aesthetic)
                Chart {
                    // UPDATED: Iterate over weeklyCalorieChartData and use dailyCalorieGoal
                    ForEach(data.weeklyCalorieChartData, id: \.day) { entry in
                        BarMark(
                            x: .value("Day", entry.day),
                            y: .value("Calories", Double(entry.calories))
                        )
                        .foregroundStyle(
                            Double(entry.calories) >= data.dailyCalorieGoal
                            ? Color.orange.gradient
                            : Color.orange.opacity(0.5).gradient
                        )
                        .cornerRadius(6)
                        .annotation(position: .top, spacing: 4) {
                            if entry.calories > 0 {
                                Text("\(entry.calories)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    RuleMark(y: .value("Target", data.dailyCalorieGoal))
                        .foregroundStyle(.red.opacity(0.6))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Daily Goal")
                                .font(.caption2.bold())
                                .foregroundStyle(.red.opacity(0.7))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.red.opacity(0.08), in: Capsule())
                        }
                }
                .chartYScale(domain: 0...800)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .stride(by: 200)) { value in
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text("\(Int(v))")
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3]))
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption.bold())
                    }
                }
                .frame(height: 260)
                .padding(.vertical, 8)
                
                // MARK: - Insight Card
                VStack(alignment: .leading, spacing: 8) {
                    Label("Insight", systemImage: "lightbulb.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                    
                    // UPDATED: Filter using weeklyCalorieChartData
                    let overTargetDays = data.weeklyCalorieChartData.filter { Double($0.calories) >= data.dailyCalorieGoal }.count
                    Text("You hit your daily calorie target on **\(overTargetDays) of 7** days this week. \(overTargetDays >= 5 ? "Excellent consistency!" : "Keep pushing!")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding()
        }
        .navigationTitle("Weekly Calories")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: UserCalorieIntake.self, destination: { value in
            UserCalorieIntake()
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: UserCalorieIntake()) {
                    Text("Edit")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
    
    private func statPill(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.headline.monospacedDigit())
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        CalorieBreakdownView()
            .environment(WorkoutSummaryManager())
    }
}
