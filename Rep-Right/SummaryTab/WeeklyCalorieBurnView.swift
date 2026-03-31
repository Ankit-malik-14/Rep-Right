import SwiftUI
import Charts

struct DailyCalorie: Identifiable {
    let id = UUID()
    let day: String
    let calories: Int
}

struct WeeklyCalorieBurnView: View {
    let mockData: [DailyCalorie] = [
        DailyCalorie(day: "Mon", calories: 320),
        DailyCalorie(day: "Tue", calories: 450),
        DailyCalorie(day: "Wed", calories: 280),
        DailyCalorie(day: "Thu", calories: 510),
        DailyCalorie(day: "Fri", calories: 390),
        DailyCalorie(day: "Sat", calories: 600),
        DailyCalorie(day: "Sun", calories: 420)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Weekly Calorie Burn")
                    .font(.title3)
                    .bold()
                
                Text("Daily metabolic output trend")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 30)
            
            Chart(mockData) { item in
                LineMark(
                    x: .value("Day", item.day),
                    y: .value("Calories", item.calories)
                )
                //.interpolationMethod(.catmullRom)
                .foregroundStyle(.orange)
                //.lineStyle(StrokeStyle(lineWidth: 3))
                
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
                HStack(spacing: 2) {
                    Text("5635")
                        .bold()
                    Text("Kcal")
                        .font(.caption)
                        .bold()
                }
                
                Spacer()
                
                Text("80% of Weekly Calorie Target")
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                //.background(Color.white.cornerRadius(15))
        )
        .padding(.horizontal)
    }
}

#Preview {
    WeeklyCalorieBurnView()
}

