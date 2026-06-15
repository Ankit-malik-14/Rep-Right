import SwiftUI

struct FormInsightView: View {
    // Access the Summary tab's view model
    @Environment(SummaryDashboardViewModel.self) private var viewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.18))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Form Insight")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .bold()
                
                // Access through view model
                Text(viewModel.latestFormInsight ?? "Complete a session with AI Assistance to get personalized form insights.")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
        .padding(.horizontal)
    }
}

#Preview {
    FormInsightView()
        .environment(WorkoutSummaryManager())
}
