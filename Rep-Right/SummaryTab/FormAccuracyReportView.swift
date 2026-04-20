import SwiftUI

struct FormAccuracyReportView: View {
    // Fetched from SummaryDataModel: reads the average form accuracy
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Form Accuracy Report")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .bold()
                    
                    Text("Your form accuracy based on previous sessions")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                // Fetched from SummaryDataModel: averageFormAccuracy computed property (0.0–1.0)
                Gauge(value: summaryManager.averageFormAccuracy, in: 0...1) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(Int(summaryManager.averageFormAccuracy * 100))%")
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
            
            Button(action: {
            }) {
                Text("View Detailed Form Trends")
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.orange)
                    .cornerRadius(10)
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

#Preview {
    FormAccuracyReportView()
        .environment(WorkoutSummaryManager())
}
