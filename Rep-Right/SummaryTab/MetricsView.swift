import SwiftUI

struct MetricsView: View {
    // Fetched from SummaryDataModel: Access global summary manager
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink(value: SummaryRoute.metricRing) {
                HStack(spacing: 6) {
                    Text("Metrics")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.black)
                    Image(systemName: "chevron.right")
                        .font(.headline)
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
            .padding(16)
            .appCardStyle()
        }
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
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }
}

#Preview {
    MetricsView()
        .environment(WorkoutSummaryManager())
}
