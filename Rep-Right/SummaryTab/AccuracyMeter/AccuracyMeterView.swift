import SwiftUI

struct AccuracyMeterView: View {

    @State var value: Double
    // Fetched from DataModel: exercise name passed from parent navigation
    var exerciseName: String
    
//    var body: some View {
//        VStack{
//            NavigationStack{
//                ScrollView{
//                    GaugesView(value: $value)
//                        .padding(.vertical)
//                    LevelView(value: $value)
//                    MotivationalQuote(value:$value)
//                        .padding(.vertical)
//
//    var service: PoseDetectionService? = nil
//    var staticValue: Double? = nil
//
//    var displayValue: Double {
//        service?.formAccuracy ?? staticValue ?? 0
//    }
//    var displayFeedback: [String] {
//        service?.currentFeedback ?? ["Great form! Keep it up."]
//    }
//    var displayRisks: [String] {
//        service?.currentRisks ?? []
//    }

    @State private var animatedValue: Double = 0

    var body: some View {
        ScrollView {
            GaugesView(value: $animatedValue)
                .padding(.vertical)

            LevelView(value: $animatedValue)

            Divider()

            MotivationalQuote(value: $animatedValue)

            Divider()
                .padding(.vertical)

            RiskView()
        }
        .navigationTitle(exerciseName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                animatedValue = value
            }
        }
    }
}

// MARK: - Live Risk View
struct LiveRiskView: View {
    var risks: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Possible Risk")
                .font(.headline.bold())
            ForEach(risks, id: \.self) { risk in
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(risk).font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).foregroundStyle(.background.secondary))
        .padding(.horizontal)
    }
}

// MARK: - Live Suggestion View
struct LiveSuggestionView: View {
    var suggestions: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestion")
                .font(.headline.bold())
            ForEach(suggestions, id: \.self) { tip in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(tip).font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).foregroundStyle(.background.secondary))
        .padding(.horizontal)
    }
}

#Preview {
    AccuracyMeterView(value: 54.7, exerciseName: "Deadlift"/*staticValue: 72.0*/)

}
