import SwiftUI

struct FormAccuracyCardView: View {

    private let accuracy: Double = 0.87

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Form Accuracy Report")
                        .font(.system(size: 16, weight: .bold))

                    Text("Your form accuracy based on previous sessions")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Native Gauge for circular progress
                Gauge(value: accuracy) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(Int(accuracy * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.orange)
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(.orange)
                .scaleEffect(1.3)
                .frame(width: 52, height: 52)
            }

            // CTA button
            Button(action: {}) {
                Text("View Detailed Form Trends")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.orange.opacity(0.1))
                    )
            }
            .buttonStyle(.plain)
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
    FormAccuracyCardView()
        .background(Color(.systemGroupedBackground))
}
