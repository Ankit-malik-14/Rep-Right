import SwiftUI

struct FormInsightView: View {
    // Fetched from SummaryDataModel: reads the latest form insight string
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.5))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.primary)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Form Insight")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .bold()
                
                // Fetched from SummaryDataModel: latestFormInsight computed property
                Text(summaryManager.latestFormInsight ?? "Complete a session with AI Assistance to get personalized form insights.")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    FormInsightView()
        .environment(WorkoutSummaryManager())
}
