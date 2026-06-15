import SwiftUI
import Charts

struct DailyCalorie: Identifiable {
    let id = UUID()
    let day: String
    let calories: Int
}

struct WeeklyCalorieBurnView: View {
    // Access the Summary tab's view model
    @Environment(SummaryDashboardViewModel.self) private var viewModel
    
    var dynamicData: [DailyCalorie] {
        viewModel.weeklyCalorieChartData.map { DailyCalorie(day: $0.day, calories: $0.calories) }
    }
    
    var totalCalories: Int {
        viewModel.totalCaloriesBurnedCurrentWeek
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                NavigationLink(value: SummaryRoute.calorieBreakdown) {
                    HStack(spacing: 6) {
                        Text("Weekly Calorie Burn")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .bold()
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .padding(.top, 2)
                            .tint(.orange)
                    }
                }
                
                Text("Daily metabolic output trend")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 30)
            
            Chart(dynamicData) { item in
                LineMark(
                    x: .value("Day", item.day),
                    y: .value("Calories", item.calories)
                )
                .foregroundStyle(.orange)
                
                AreaMark(
                    x: .value("Day", item.day),
                    y: .value("Calories", item.calories)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange.opacity(0.3), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 120)
            .padding(.horizontal, 20)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let dayStr = value.as(String.self) {
                            Text(String(dayStr.prefix(1)))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            
            Divider()
                .padding(.horizontal, 20)
                .padding(.top, 10)
            
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                HStack(spacing: 5) {
                    Text("\(totalCalories)")
                        .bold()
                    Text("Kcal")
                        .bold()
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .appCardStyle()
        .padding(.horizontal)
    }
}

#Preview {
    WeeklyCalorieBurnView()
        .environment(WorkoutSummaryManager())
}
