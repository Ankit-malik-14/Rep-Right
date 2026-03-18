//
//  OnboardingScreen1.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 17/03/26.
//

import SwiftUI

struct OnboardingScreen1: View {
    var body: some View {
        VStack{
            Image(systemName: "dumbbell.fill")
                .font(.largeTitle)
                .bold()
            
        }
    }
}

struct tabView: View {
    var body: some View {
        TabView {
            Tab("home", image:"") {
                
            }
        }
    }
}

#Preview {
    OnboardingScreen1()
}
