import SwiftUI

struct OnboardingScreenView2: View {
    var body: some View {
        VStack(spacing: 0) {
            
            Image(.deadlift)
                .resizable()
                .scaledToFill()
                .frame(height: 500)
                .clipShape(
                    UnevenRoundedRectangle(bottomLeadingRadius: 50, bottomTrailingRadius: 50)
                )
                .ignoresSafeArea(edges: .top)
                .padding(.bottom, 32)
            
            // Text Section
            VStack(spacing: 16) {
                Text("Perfect your form")
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                
                Text("Helps reduce risk of injuries with instant alerts when\nyour posture needs adjustment.")
                    .font(.system(size: 20, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingScreenView2()
}
