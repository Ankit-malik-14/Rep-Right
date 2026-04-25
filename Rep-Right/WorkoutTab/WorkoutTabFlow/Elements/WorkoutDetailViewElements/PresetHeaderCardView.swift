//
//  HeaderAnatomyView.swift
//  PresettFlow
//
//  Created by Jugad on 18/03/26.
//

import SwiftUI



struct PresetHeaderCardView: View {
    var upper = ["Back", "Chest", "Shoulders", "Arms","Core"]
    var image: String
    var body: some View {
        if image == ""{
            ZStack {
                Color(UIColor.systemGray6)// needs shape fixing, UIColor is not prefered in SwiftUi
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
        else{
            ZStack {
                //Color(UIColor.systemGray6) needs shape fixing, UIColor is not prefered in SwiftUi
                // Placeholder for the muscle image
                if upper.contains(image){
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 600, height: 450)
                        .foregroundColor(.gray)
                        .offset(y:150)
                    
                        .padding(.top, 20)
                        .padding(.bottom, 60)
                }
                else{
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 500, height: 450)
                        .foregroundColor(.gray)
                        .offset(y:-100)
                    
                        .padding(.top, 20)
                        .padding(.bottom, 60)
                }
            }
            .frame(height: 260)
            .cornerRadius(20)
        }
    }
}


#Preview {
    PresetHeaderCardView(image: "Legs")

}
