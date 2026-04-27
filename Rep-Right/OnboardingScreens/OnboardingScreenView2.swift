import SwiftUI

struct OnboardingScreenView2: View {
    var body: some View {
        VStack(spacing: 10) {
            
            Image("PullUp-Onboarding")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 600)
                .clipShape(
                    UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40)
                )
               
//                .padding(.bottom, 32)
            
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
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    OnboardingScreenView2()
}
