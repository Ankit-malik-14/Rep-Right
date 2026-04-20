//
//  SuggestionView.swift
//  Rep-Right
//

import SwiftUI

struct SuggestionView: View {
    // Fetched from SummaryDataModel/parent: suggestion strings passed in dynamically
    var suggestions: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestion")
                .font(.headline)
                .fontWeight(.bold)
            
            if suggestions.isEmpty {
                Text("Complete more sessions to get suggestions.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(suggestions, id: \.self) { suggestion in
                    suggestionRow(text: suggestion)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background (
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.background.secondary)
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func suggestionRow(text: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    SuggestionView(suggestions: ["Brace core tightly to protect spine.", "Hinge hips while keeping back flat."])
}
