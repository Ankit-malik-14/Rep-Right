//
//  RiskView.swift
//  Rep-Right
//

import SwiftUI

struct RiskView: View {
    // Fetched from DataModel/parent: risk strings passed in dynamically
    var risks: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Possible Risk")
                .font(.headline)
                .fontWeight(.bold)
            
            if risks.isEmpty {
                Text("No specific risks identified yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(risks, id: \.self) { risk in
                    riskRow(text: risk)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment:.leading)
        .background (
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.background.secondary)
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func riskRow(text: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    RiskView(risks: ["Disc Herniation", "Ligament & Muscle Tears"])
}
