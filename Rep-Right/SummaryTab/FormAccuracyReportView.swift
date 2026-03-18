import SwiftUI

struct FormAccuracyReportView: View {
    let accuracyIndicator: Double = 0.85
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Form Accuracy Report")
                        .font(.headline)
                        .bold()
                    
                    Text("Your form accuracy based on previous sessions")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Circular Progress using Apple's Gauge
                Gauge(value: accuracyIndicator, in: 0...1) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(Int(accuracyIndicator * 100))%")
                        .font(.callout)
                        .bold()
                }
                .gaugeStyle(.accessoryCircular)
                .tint(.orange)
                .scaleEffect(1.5) // Scale it up to match the previous size
                .frame(width: 70, height: 70)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Button(action: {
                // Action for detailed trends
            }) {
                Text("View Detailed Form Trends")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Color.white.cornerRadius(15))
        )
        .padding(.horizontal)
    }
}

#Preview {
    FormAccuracyReportView()
}

