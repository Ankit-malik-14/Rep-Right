import SwiftUI

struct SummaryTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(spacing: 20) {
                    CalendarView()
                    NavigationLink(destination: MetricRingView()) {
                        MetricsView()
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: CalorieBreakdownView()) {
                        WeeklyCalorieBurnView()
                    }
                    .buttonStyle(.plain)
                    FormInsightView()
                    FormAccuracyReportView()
                    
                }
            .padding(.bottom)
            }

            .navigationTitle("Summary")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ProfileFormView()) {
                        Image(systemName: "person.circle.fill")
                    }
                }
            }
        }
    }
}

#Preview {
    SummaryTabView()
        .environment(WorkoutSummaryManager())
}

