import SwiftUI

struct OnboardingScreenView2: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .center) {
                UnevenRoundedRectangle(bottomLeadingRadius: 30, bottomTrailingRadius: 30)
                    .fill(Color(red: 0.98, green: 0.92, blue: 0.86))
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
