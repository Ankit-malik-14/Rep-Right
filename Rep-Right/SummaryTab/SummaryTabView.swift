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
                    
                }.navigationDestination(for: UserProfile.self, destination: { userProfile in
                    UserProfileView()
                })
            .padding(.bottom)
            }

            .navigationTitle("Summary")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: DummyUserProfiles().user) {
                        Image(systemName: "person.circle.fill")
                    }
                }
            
            }
        }
    }
}

#Preview {
    SummaryTabView()
}

