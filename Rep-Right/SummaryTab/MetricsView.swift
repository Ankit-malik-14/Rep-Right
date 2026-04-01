import SwiftUI

struct MetricsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Metrics")
                .font(.title2)
                .bold()
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
                .padding(.top)
            
            HStack(spacing: 10) {
                MetricCard(
                    icon: "dumbbell.fill",
                    title: "Exercise",
                    value: "14",
                    change: "+2"
                )

                MetricCard(
                    icon: "timer",
                    title: "Time",
                    value: "6.5",
                    change: "+1.5"
                )

                MetricCard(
                    icon: "calendar",
                    title: "Streak",
                    value: "14",
                    change: "+1"
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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

                Text(change)
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
            MetricsView()
}
