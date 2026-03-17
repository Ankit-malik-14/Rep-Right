//
//  OnboardingScreen1.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 17/03/26.
//

import SwiftUI

struct AllOnboardingScreens: View {
    var body: some View {
        TabView{
            Tab(){
                OnboardingScreen1()
            }
            Tab(){
                OnboardingScreen1()
            }
        }.tabViewStyle(.page)
    }
}


struct OnboardingScreen1: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack{
            VStack{
                Image(systemName: "dumbbell.fill")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                VStack{
                    Text("Your Personal AI Fitness Assistance")
                        .font(.largeTitle)
                        .bold()
                    //                    .padding()
                    Text("Real-time posture assistance and workout plans to help you reach your goals safely")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
        }
    }
}

struct firstEmptyView: View{
    @State private var showSheet: Bool = true
    var body: some View{
        VStack{
            Text("hii")
        }
        .sheet(isPresented: $showSheet){
            OnboardingScreen1()
        }
    }
}

#Preview {
    OnboardingScreen1()
}
