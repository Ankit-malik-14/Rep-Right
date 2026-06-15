import SwiftUI

struct SummaryTabView: View {
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(UserProfileModel.self) private var userProfile
    @Environment(Exercises.self) private var exercises

    @State private var viewModel: SummaryDashboardViewModel?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                SummaryTabContent()
                    .environment(viewModel)
            } else {
                Color.clear
                    .onAppear {
                        viewModel = SummaryDashboardViewModel(
                            summaryManager: summaryManager,
                            userProfile: userProfile,
                            exercises: exercises
                        )
                    }
            }
        }
    }
}

struct SummaryTabContent: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    CalendarView()
                    MetricsView()
                    WeeklyCalorieBurnView()
                    FormInsightView()
                    FormAccuracyReportView()
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
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
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    SummaryTabView()
        .environment(WorkoutSummaryManager())
        .environment(Exercises())
        .environment(UserProfileModel())
}
