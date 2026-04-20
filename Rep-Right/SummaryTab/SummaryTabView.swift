import SwiftUI

struct SummaryTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(spacing: 20) {
                    CalendarView()
                    NavigationLink(value: MetricRingView()) {
                        MetricsView()
                    }
//                    NavigationLink(destination: MetricRingView()) {
//                        MetricsView()
//                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(value: CalorieBreakdownView()) {
                        WeeklyCalorieBurnView()
                    }
                    .buttonStyle(.plain)
                    FormInsightView()
                    FormAccuracyReportView()
                    
                }
            .padding(.bottom)
            }
            .navigationDestination(for: MetricRingView.self, destination: { value in
                MetricRingView()
            })
            .navigationDestination(for: CalorieBreakdownView.self, destination: { value in
                CalorieBreakdownView()
            })

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

