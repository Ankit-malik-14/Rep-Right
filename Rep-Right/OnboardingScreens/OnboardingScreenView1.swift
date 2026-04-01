import SwiftUI

struct OnboardingScreenView1: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                // Main Image Area
                UnevenRoundedRectangle(bottomLeadingRadius: 30, bottomTrailingRadius: 30)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(.aIassistance)
                            .resizable()
                            .scaledToFill() 
                    )
                    .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 30, bottomTrailingRadius: 30))
                    .ignoresSafeArea(edges: .top)
                
                // Assistance Button
                HStack(spacing: 4) {
                    Image(systemName: "camera")
                        .font(.system(size: 12))
                    Text("Assistance")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.orange)
                .clipShape(Capsule()) // Capsule gives a perfect pill shape
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .frame(height: 480) // Adjusted height slightly to match proportions better
            .padding(.bottom, 32)
                        
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
