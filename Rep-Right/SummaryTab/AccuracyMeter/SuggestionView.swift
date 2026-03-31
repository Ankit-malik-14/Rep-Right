//
//  SuggestionView.swift
//  Rep-Right
//
//  Created by GU on 17/03/26.
//

import SwiftUI

struct SuggestionView: View {
    // We have to use State Bindng depends on accuracy 
    let suggestionText = "Brace core tightly to protect spine."
    let suggestionText2 = "Hinge hips while keeping back flat."

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestion")
                .font(.headline)
                .fontWeight(.bold)
            
            suggestionRow(text: suggestionText)
            suggestionRow(text: suggestionText2)
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
    SuggestionView()
}
