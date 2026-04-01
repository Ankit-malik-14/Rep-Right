import SwiftUI

struct OnboardingContainerView: View {
    var body: some View {
        TabView {
            Tab("onboarding1",image: ""){
                OnboardingScreenView1()
            }
            Tab("onboarding2",image: ""){
                OnboardingScreenView2()
            }
            Tab("onboarding2",image: ""){
                OnboardingScreenView3()
            }
        }.tabViewStyle(.page)
            .ignoresSafeArea()
    }
}

#Preview {
    OnboardingContainerView()
}
