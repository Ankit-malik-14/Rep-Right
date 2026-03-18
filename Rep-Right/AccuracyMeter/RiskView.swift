//
//  RiskView.swift
//  Rep-Right
//
//  Created by GU on 17/03/26.
//
import SwiftUI

struct RiskView: View {
    let riskText = "Your Back"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Possible Risk")
                .font(.headline)
                .fontWeight(.bold)
            
            riskRow(text: riskText)
            riskRow(text: riskText)
        }
        .padding()
        //Leading is used to make it alingment
        .frame(maxWidth: .infinity, alignment:.leading)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.background.secondary)
        }
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
    RiskView()
}
