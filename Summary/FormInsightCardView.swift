import SwiftUI

struct FormInsightCardView: View {

    var body: some View {
        HStack(spacing: 14) {
            // Left icon circle
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 48, height: 48)

                Image(systemName: "lightbulb.max")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black)
            }

            // Text content
            VStack(alignment: .leading, spacing: 3) {
                Text("Form Insight")
                    .font(.system(size: 16, weight: .bold))

                Text("Your depth on Barbell Squats improved by 12%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Angle badge
          
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
    FormInsightCardView()
        .background(Color(.systemGroupedBackground))
}
