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
            // MARK: - Single navigation destination for the entire Summary tab
            .navigationDestination(for: SummaryRoute.self) { route in
                switch route {
                case .calorieBreakdown:
                    CalorieBreakdownView()
                case .metricRing:
                    MetricRingView()
                case .userCalorieIntake:
                    UserCalorieIntake()
                case .exerciseAccuracyList:
                    ExerciseAccuracyListView()
                case .accuracyMeter(let value, let name, let insights):
                    AccuracyMeterView(value: value, exerciseName: name, insights: insights)
                case .profile:
                    ProfileFormView()
                }
            }
            .navigationTitle("Summary")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: SummaryRoute.profile) {
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
        .environment(Exercises())
        .environment(UserProfileModel())
}
