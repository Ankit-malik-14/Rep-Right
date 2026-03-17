//
//  RiskView.swift
//  Rep-Right
//
//  Created by GU on 17/03/26.
//

import SwiftUI

struct PossibleRisk: View {
    var body: some View {
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 100)
                .foregroundStyle(.background.tertiary)
            VStack(alignment: .leading){
        
                Text("Possible Risk")
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                HStack{
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text("Your Back")
                        .font(.subheadline)
                }
                HStack{
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text("Your Back")
                        .font(.subheadline)
                    
                }
                
            }
            .padding()
            
        }
    }
}

#Preview {
    PossibleRisk()
}
