import SwiftUI

struct Metrics: View {
    var body: some View {

        VStack(alignment: .leading,spacing: 9) {
            Text("Metrics")
                .font(.title)
                .bold()
                .padding(.horizontal)
            HStack(spacing: 10) {
                
                MetricCard(
                    icon: "dumbbell.fill",
                    title: "Exercises",
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
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.secondary.opacity(0.2))
        )
        .padding()
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

                Text(title)
                    .font(.subheadline)
            }

            HStack(alignment: .bottom, spacing: 5) {

                Text(value)
                    .font(.title2)
                    .bold()

                Text(change)
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity,minHeight: 90,maxHeight: 90)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.2))
        )
    }
}

#Preview {
    Metrics()
}
