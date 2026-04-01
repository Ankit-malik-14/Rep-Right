import SwiftUI

struct SummaryTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(spacing: 20) {
                    CalendarView()
                    MetricsView()
                    WeeklyCalorieBurnView()
                    FormInsightView()
                    FormAccuracyReportView()
                    
                }
            .padding(.bottom)
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

