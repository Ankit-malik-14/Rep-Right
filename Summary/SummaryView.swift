import SwiftUI

struct SummaryView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                SummaryHeaderView()

                CalendarStripView()

                MetricsCardView()

                WeeklyCalorieBurnView()

                FormInsightCardView()

                FormAccuracyCardView()
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SummaryView()
}
