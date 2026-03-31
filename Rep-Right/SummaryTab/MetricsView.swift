import SwiftUI

struct MetricsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Metrics")
                .font(.title2)
                .bold()
                .foregroundStyle(.black)
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
        .background(.white)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
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
                    .foregroundStyle(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            HStack(alignment: .bottom, spacing: 5) {
                Text(value)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.black)

                Text(change)
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
        //.background(Color(white: 0.97))
        .background(.gray.opacity(0.1))
        .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    ZStack {
        Color(white: 0.95).ignoresSafeArea()
        MetricsView()
    }
}
