import SwiftUI
import Charts

struct DailyCalorie: Identifiable {
    let id = UUID()
    let day: String
    let calories: Int
}

struct WeeklyCalorieBurnView: View {
    // Fetched from SummaryDataModel: Access global summary manager
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    
    var dynamicData: [DailyCalorie] {
        // Fetched from SummaryDataModel: Mapping weeklyCalorieChartData to DailyCalorie
        summaryManager.weeklyCalorieChartData.map { DailyCalorie(day: $0.day, calories: $0.calories) }
    }
    
    var totalCalories: Int {
        // Fetched from SummaryDataModel: Sum of current week calories
        dynamicData.reduce(0) { $0 + $1.calories }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                NavigationLink(value: SummaryRoute.calorieBreakdown) {
                    HStack{
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
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    WeeklyCalorieBurnView()
        .environment(WorkoutSummaryManager())
}
