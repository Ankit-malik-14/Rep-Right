import SwiftUI

struct MetricsCardView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Metrics")
                .font(.headline)

            HStack(spacing: 12) {
                MetricPill(
                    icon: "figure.strengthtraining.traditional",
                    label: "Exercises",
                    value: "14",
                    delta: "+2",
                    color: .orange
                )

                MetricPill(
                    icon: "clock.fill",
                    label: "Time",
                    value: "6.5",
                    unit: "h.5",
                    delta: nil,
                    color: .orange
                )

                MetricPill(
                    icon: "flame.fill",
                    label: "Streak",
                    value: "14",
                    delta: "+1",
                    color: .orange
                )
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

// MARK: - Metric Pill

private struct MetricPill: View {
    let icon: String
    let label: String
    let value: String
    var unit: String? = nil
    var delta: String? = nil
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(color)

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))

                if let unit {
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                if let delta {
                    Text(delta)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(color)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.opacity(0.08))
        )
    }
}

#Preview {
    MetricsCardView()
        .background(Color(.systemGroupedBackground))
}
