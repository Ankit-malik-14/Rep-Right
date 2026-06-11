//
//  SinglePageOnboardingView.swift
//  Rep_Right
//
//  Created by Mayurakshi Das on 27/04/26.
//

import SwiftUI

import SwiftUI

struct OnboardingScreenView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var showPersonalise = false

    struct Feature {
        let icon: String
        let title: String
        let description: String
    }

    let features: [Feature] = [
        Feature(
            icon: "figure.strengthtraining.traditional",
            title: "Your Personal AI Coach",
            description: "Get real-time feedback and custom workout plans tailored to your body and goals."
        ),
        Feature(
            icon: "camera.viewfinder",
            title: "Perfect Your Form",
            description: "Helps reduce risk of injuries with instant alerts when your posture needs adjustment."
        ),
        Feature(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "See detailed metrics, streaks, and performance summaries after every session."
        ),
        Feature(
            icon: "calendar.badge.checkmark",
            title: "Plan Your Success",
            description: "Schedule your splits and track your consistency with detailed summaries."
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome to")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.black)
                        Text("Rep-Right")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                    .padding(.top, 72)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)

                    // Feature rows
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(features, id: \.title) { feature in
                            HStack(alignment: .top, spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.12))
                                        .frame(width: 52, height: 52)
                                    Image(systemName: feature.icon)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(.orange)
                                }
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(feature.title)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.black)
                                    Text(feature.description)
                                        .font(.system(size: 15))
                                        .foregroundStyle(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.horizontal, 28)
                        }
                    }

                    Spacer().frame(height: 120)
                }
            }

            // Button pinned to bottom
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.white.opacity(0), Color.white],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 32)

                Button {
                    showPersonalise = true
                } label: {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.orange)
                        .clipShape(Capsule())
                        .padding(.horizontal, 28)
                }
                .padding(.bottom, 36)
                .background(Color.white)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showPersonalise) {
            OnboardingScreenView4 {
                hasSeenOnboarding = true
                showPersonalise = false
            }
        }
    }
}

#Preview {
    OnboardingScreenView(hasSeenOnboarding: .constant(false))
        .environment(UserProfileModel())
        .environment(WorkoutSummaryManager())
}
