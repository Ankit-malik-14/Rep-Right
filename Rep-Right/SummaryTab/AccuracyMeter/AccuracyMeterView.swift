import SwiftUI

struct AccuracyMeterView: View {

    @State var value: Double
    var exerciseName: String
    var insights: [String] = []
    
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

            SuggestionView(suggestions: insights)
            
            Divider()
                .padding(.vertical)
            
            RiskView(risks: derivedRisks)
        }
        .navigationTitle(exerciseName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                animatedValue = value
            }
        }
    }
    
    private var derivedRisks: [String] {
        switch value {
        case ..<35:
            return ["Form breakdown is high. Reduce load and slow the tempo until the movement is stable."]
        case ..<70:
            return ["Inconsistent positioning may limit progress. Review the cues below before your next set."]
        default:
            return ["Low injury risk detected from the assisted session. Focus on maintaining this pattern."]
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
    AccuracyMeterView(value: 54.7, exerciseName: "Deadlift", insights: ["Brace your core before each rep.", "Keep your shoulders stacked over the bar."])

}
