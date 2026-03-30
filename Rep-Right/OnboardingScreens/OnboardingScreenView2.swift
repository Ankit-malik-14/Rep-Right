import SwiftUI

struct OnboardingScreenView2: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .center) {
                // Replaced solid fill with a clipped image
                Image(.AI)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 450) // Constrains the image so it scales correctly
                    .clipShape(
                        UnevenRoundedRectangle(bottomLeadingRadius: 30, bottomTrailingRadius: 30)
                    )
                    .ignoresSafeArea(edges: .top)
            }
            .frame(height: 450)
            .padding(.bottom, 32)
            
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
