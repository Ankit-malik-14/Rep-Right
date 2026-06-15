import SwiftUI

struct FormAccuracyReportView: View {
    // Access the Summary tab's view model
    @Environment(SummaryDashboardViewModel.self) private var viewModel
    
    var body: some View {
        let latestRecord = viewModel.latestFormAccuracyRecord
        let latestAccuracy = latestRecord?.formAccuracy ?? 0
        let latestInsights = latestRecord?.formInsights ?? []
        let averagePercent = Int(viewModel.averageFormAccuracy * 100)
        
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Form Accuracy Report")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .bold()
                    
                    Text(averageStatusMessage(for: averagePercent, hasAccuracyData: latestRecord != nil))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                Gauge(value: viewModel.averageFormAccuracy, in: 0...1) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(Int(viewModel.averageFormAccuracy * 100))%")
                        .font(.callout)
                        .bold()
                }
                .gaugeStyle(.accessoryCircular)
                .tint(.orange)
                .scaleEffect(1.5)
                .frame(width: 70, height: 70)
                .padding(.trailing, 15)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            if latestRecord != nil {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Current Form Status")
                            .font(.subheadline.bold())
                        Spacer()
                        Text("\(averagePercent)/100 Avg")
                            .font(.subheadline.bold())
                            .foregroundStyle(.orange)
                    }
                    
                    Gauge(value: viewModel.averageFormAccuracy, in: 0...1) {
                        EmptyView()
                    }
                    .tint(Gradient(colors: [.red, .yellow, .green]))
                    
                    Text(latestInsights.first ?? averageStatusDetail(for: averagePercent))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
            }
            
            NavigationLink(value: SummaryRoute.exerciseAccuracyList) {
                Text("View Detailed Form Trends")
            }
            .buttonStyle(AppPrimaryButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .appCardStyle()
        .padding(.horizontal)
    }
    
    private func averageStatusMessage(for averagePercent: Int, hasAccuracyData: Bool) -> String {
        guard hasAccuracyData else {
            return "Complete an assisted set to start tracking your average form quality over time."
        }
        
        switch averagePercent {
        case 85...100:
            return "Your recent assisted sessions show strong overall mechanics with only small corrections needed."
        case 70..<85:
            return "Your average form is trending in a solid direction, but a few repeat positioning issues are still worth tightening up."
        case 50..<70:
            return "Your form is showing some consistency, but repeated breakdowns are still limiting overall movement quality."
        default:
            return "Your assisted sessions are catching major form breakdowns right now, so slower reps and tighter positioning should be the priority."
        }
    }
    
    private func averageStatusDetail(for averagePercent: Int) -> String {
        switch averagePercent {
        case 85...100:
            return "You are maintaining strong technique across recent assisted sessions. Keep reinforcing the same setup and bracing habits."
        case 70..<85:
            return "Your form is mostly stable, but cleaning up the most common correction cues should noticeably improve consistency."
        case 50..<70:
            return "There is good potential here, but your movement pattern still breaks down often enough that focused cue-by-cue practice will help."
        default:
            return "Your current form accuracy suggests the movement needs more control and deliberate setup before intensity or speed increases."
        }
    }
}

#Preview {
    FormAccuracyReportView()
        .environment(WorkoutSummaryManager())
}
