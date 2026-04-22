//
//  AccuracyMeterView.swift
//  Rep-Right
//

//  Created by Mayurakshi on 17/03/26.
//
//
//  AccuracyMeterView.swift
//  Rep-Right
//
//  REPLACE your existing file with this.
//  Change: accepts staticValue: Double for history list,
//          or a live PoseDetectionService for real-time use.
//


import SwiftUI

struct AccuracyMeterView: View {

    @State var value: Double
    // Fetched from DataModel: exercise name passed from parent navigation
    var exerciseName: String
    
    var body: some View {
        VStack{
            NavigationStack{
                ScrollView{
                    GaugesView(value: $value)
                        .padding(.vertical)
                    LevelView(value: $value)
                    MotivationalQuote(value:$value)
                        .padding(.vertical)

    var service: PoseDetectionService? = nil
    var staticValue: Double? = nil

    var displayValue: Double {
        service?.formAccuracy ?? staticValue ?? 0
    }
    var displayFeedback: [String] {
        service?.currentFeedback ?? ["Great form! Keep it up."]
    }
    var displayRisks: [String] {
        service?.currentRisks ?? []
    }

    @State private var animatedValue: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                GaugesView(value: $animatedValue)
                    .padding(.vertical)

                LevelView(value: $animatedValue)

                Divider()

                MotivationalQuote(value: $animatedValue)

                Divider()
                    .padding(.vertical)

                if !displayRisks.isEmpty {
                    LiveRiskView(risks: displayRisks)
                } else {

                    RiskView()
                }
                // Fetched from DataModel: dynamic exercise name instead of hardcoded "Exercise Name"
                .navigationTitle(exerciseName)
                .font(.system(size: 20, weight: .bold, design: .default))
                .navigationBarTitleDisplayMode(.inline)


                LiveSuggestionView(suggestions: displayFeedback)
            }
            .navigationTitle("Form Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                animatedValue = displayValue
            }
            .onChange(of: displayValue) { _, newVal in
                withAnimation(.easeOut(duration: 0.4)) {
                    animatedValue = newVal
                }

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
    AccuracyMeterView(staticValue: 72.0)

}
