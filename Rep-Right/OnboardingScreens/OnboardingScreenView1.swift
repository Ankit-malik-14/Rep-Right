import SwiftUI

struct OnboardingScreenView1: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("Deadlift-Onboarding")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 600)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40))
                
            // Text Section
            VStack(spacing: 16) {
                Text("Your Personal\nAI Fitness Assistance")
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                
                Text("Real-time posture assistance and\nworkout plans to help you\nreach your goals safely")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
            }
            
            .padding(.horizontal, 24)
            
            Spacer()
            
        }
       
        .ignoresSafeArea(.all, edges: .top) // Ensures the whole VStack can push into the top safe area
    }
}

#Preview {
    OnboardingScreenView1()
}
