import SwiftUI
import Charts

struct WeeklyCalorieBurnView: View {

    private let data: [(day: String, value: Double)] = [
        ("Mon", 400),
        ("Tue", 650),
        ("Wed", 550),
        ("Thu", 900),
        ("Fri", 850),
        ("Sat", 700),
        ("Sun", 750)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text("Weekly Calorie Burn")
                    .font(.headline)

                Text("Daily metabolic output trend")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Chart
            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    AreaMark(
                        x: .value("Day", item.day),
                        y: .value("Calories", item.value)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [Color.orange.opacity(0.5), Color.orange.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day", item.day),
                        y: .value("Calories", item.value)
                    )
                    .foregroundStyle(Color.orange)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 140)

            // Bottom stats row
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.orange)

                Text("5635 kcal")
                    .font(.system(size: 13, weight: .semibold))

                Spacer()

                Text("80% of Weekly Calorie Target")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    WeeklyCalorieBurnView()
        .background(Color(.systemGroupedBackground))
}
