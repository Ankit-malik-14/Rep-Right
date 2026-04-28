import SwiftUI

struct MetricsView: View {
    // Fetched from SummaryDataModel: Access global summary manager
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            NavigationLink(value: SummaryRoute.metricRing) {
                HStack{
                    Text("Metrics")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.black)
                        .padding(.leading, 20)
                        .padding(.top)
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .padding(.top,18)
                        .tint(.orange)
                }
            }
            
            HStack(spacing: 10) {
                MetricCard(
                    icon: "dumbbell.fill",
                    title: "Exercise",
                    // Fetched from SummaryDataModel: total exercises this week
                    value: "\(summaryManager.totalExercisesCurrentWeek)",
                    change: ""
                )

                MetricCard(
                    icon: "timer",
                    title: "Time",
                    // Fetched from SummaryDataModel: total time this week in hours
                    value: String(format: "%.1f", summaryManager.totalTimeCurrentWeekInHours),
                    change: ""
                )

                MetricCard(
                    icon: "calendar",
                    title: "Streak",
                    // Fetched from SummaryDataModel: current active streak
                    value: "\(summaryManager.currentStreak)",
                    change: ""
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.background.secondary)
        )
        .padding(.horizontal)
    }
}

struct MetricCard: View {
    var icon: String
    var title: String
    var value: String
    var change: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.orange)
                    .font(.caption)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            HStack(alignment: .bottom, spacing: 5) {
                Text(value)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.primary)

                if !change.isEmpty {
                    Text(change)
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
        )
    }
}

#Preview {
    MetricsView()
        .environment(WorkoutSummaryManager())
}
