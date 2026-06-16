//
//  ContentView.swift
//  Rep_Right
//
//  Created by Jugad on 19/04/26.
//


import SwiftUI

struct ContentView: View {
    // 1. @AppStorage persisting boolean state across app launches.
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var isShowingSplash = true
    
    var body: some View {
        Group {
            if isShowingSplash {
                AppNameScreenView()
                    .transition(.opacity)
            } else if !hasSeenOnboarding {
                ActiveOnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                HomeView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowingSplash)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasSeenOnboarding)
        .task {
            try? await Task.sleep(for: .seconds(1.5))
            isShowingSplash = false
        }
    }
}

#Preview {
    ContentView()
}
