import SwiftUI
import Charts

struct totalTimeExerciseView: View {
    
    let moveRed = Color(red: 228/255, green: 59/255, blue: 55/255)
    let exerciseGreen = Color(red: 104/255, green: 199/255, blue: 79/255)
    let standBlue = Color(red: 22/255, green: 176/255, blue: 221/255)
    let eggYolkYellow = Color(red: 247/255, green: 188/255, blue: 36/255)
    let shinyOrange = Color(red: 253/255, green: 147/255, blue: 29/255)
    let dustyMagenta = Color(red: 151/255, green: 73/255, blue: 148/255)
    
    var weeklyStats: [(day: String, category: String, minutes: Double, color: Color)] {
        [
            ("Mon", "Chest", 50, moveRed),
            ("Tue", "Leg", 45, exerciseGreen),
            ("Wed", "Core", 30, eggYolkYellow),
            ("Thu", "Chest", 42, moveRed),
            ("Fri", "Back", 35, standBlue),
            ("Sat", "Shoulder", 25, shinyOrange)
        ]
    }
    
    var yAxisUpperLimit: Double {
        let dailyTotals = Dictionary(grouping: weeklyStats, by: { $0.day })
            .map { $0.value.reduce(0) { sum, stat in sum + stat.minutes } }
        
        let maxDailyTotal = dailyTotals.max() ?? 0
        
        return max(60, maxDailyTotal)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Weekly Activity")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Chart(weeklyStats.indices, id: \.self) { index in
                    let stat = weeklyStats[index]
                    
                    BarMark(
                        x: .value("Day", stat.day),
                        y: .value("Minutes", stat.minutes)
                    )
                    .foregroundStyle(stat.color)
                    .cornerRadius(6)
                }
                .chartXAxis {
                    AxisMarks(values: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
                }
                .chartYScale(domain: 0...yAxisUpperLimit)
                .frame(height: 300)
                .padding()
                //.background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

#Preview {
    totalTimeExerciseView()
       // .preferredColorScheme(.dark)
}
