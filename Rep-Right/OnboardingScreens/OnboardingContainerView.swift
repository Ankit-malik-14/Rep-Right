import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                OnboardingScreenView1()
                    .tag(0)
                
                OnboardingScreenView2()
                    .tag(1)
                
                OnboardingScreenView3()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? Color.orange : Color.orange.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Button(action: {}) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .clipShape(.rect(cornerRadius: 30))
                }
                .padding(.horizontal, 40)
                .opacity(currentIndex == 2 ? 1 : 0)
                .disabled(currentIndex != 2)
            }
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    OnboardingContainerView()
}
