import SwiftUI

struct SummaryTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                CalendarView()
                MetricsView()
                WeeklyCalorieBurnView()
                FormInsightView()
                FormAccuracyReportView()// needs navigation link
            }
            .padding(.vertical)
            }
            .navigationTitle("Summary")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        // Profile action
                    }) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
            
        }
    }
}

#Preview {
    SummaryTabView()
}

