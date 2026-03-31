import SwiftUI
import Charts

struct ExerciseRingView: View {
    
    let moveRed = Color(red: 228/255, green: 59/255, blue: 55/255)
    let exerciseGreen = Color(red: 104/255, green: 199/255, blue: 79/255)
    let standBlue = Color(red: 22/255, green: 176/255, blue: 221/255)
    let eggYolkYellow = Color(red: 247/255, green: 188/255, blue: 36/255)
    let shinyOrange = Color(red: 253/255, green: 147/255, blue: 29/255)
    let dustyMagenta = Color(red: 151/255, green: 73/255, blue: 148/255)
    
    var stats: [(category: String, value: Double, color: Color)] {
        [
            ("Back", 5, standBlue),
            ("Chest", 8, moveRed),
            ("Leg", 5, exerciseGreen),
            ("Core", 9, eggYolkYellow),
            ("Shoulder", 7, shinyOrange)
        ]
    }
    
    var totalSolved: Double {
        stats.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            Text("Total Exercises")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Chart(stats, id: \.category) { stat in
                SectorMark(
                    angle: .value("Exercises", stat.value),
                    innerRadius: .ratio(0.7),
                    angularInset: 2.0
                )
                .foregroundStyle(by: .value("Category", stat.category))
                .cornerRadius(6)
            }
            .chartForegroundStyleScale(
                domain: stats.map { $0.category },
                range: stats.map { $0.color }
            )
            .chartLegend(position: .bottom, alignment: .center)
            .frame(width: 250, height: 250)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    if let plotFrame = chartProxy.plotFrame {
                        let frame = geometry[plotFrame]
                        VStack {
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(totalSolved,format: .number)
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                        }
                        .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ExerciseRingView()
        //.preferredColorScheme(.dark)
}
