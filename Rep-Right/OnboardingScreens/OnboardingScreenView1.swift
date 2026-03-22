import SwiftUI

struct OnboardingScreenView1: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                UnevenRoundedRectangle(bottomLeadingRadius: 30, bottomTrailingRadius: 30)
                    .fill(Color.gray.opacity(0.2))
                    .ignoresSafeArea(edges: .top)
                    .overlay(
                        Image(systemName: "dog.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 740, height: 140)
                            .foregroundStyle(.gray)
                    )
                
                HStack(spacing: 4) {
                    Image(systemName: "camera")
                        .font(.system(size: 12))
                    Text("Assistance")
                        .font(.system(size: 12))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange)
                .clipShape(.rect(cornerRadius: 20))
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .frame(height: 450)
            .padding(.bottom, 32)
                        
            VStack(spacing: 16) {
                Text("Your Personal\nAI Fitness Assistance")
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                
                Text("Real-time posture assistance and\nworkout plans to help you\nreach your goals safely")
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingScreenView1()
}
