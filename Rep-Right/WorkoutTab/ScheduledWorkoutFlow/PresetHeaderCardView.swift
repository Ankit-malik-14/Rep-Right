//
//  HeaderAnatomyView.swift
//  PresettFlow
//
//  Created by Jugad on 18/03/26.
//

import SwiftUI

struct PresetHeaderCardView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
            
            // Placeholder for the muscle image
            Image(systemName: "figure.mind.and.body")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .frame(width: 180)
                .padding(.top, 20)
                .padding(.bottom, 60)
        }
        .frame(height: 260)
        .cornerRadius(20)
    }
}


#Preview {
    HeaderAnatomyView()

}
