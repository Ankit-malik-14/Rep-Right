import SwiftUI

struct OnboardingContainerView: View {
    @Binding var onboardingCheck: Bool
    var body: some View {
        TabView {
            Tab("onboarding1",image: ""){
                OnboardingScreenView1()
            }
            Tab("onboarding2",image: ""){
                OnboardingScreenView2()
            }
            Tab("onboarding3",image: ""){
                OnboardingScreenView3()
            }
            Tab("onboarding4",image: ""){
                OnboardingScreenView4 {
                    onboardingCheck = true
                }
            }
        }.tabViewStyle(.page)
            .ignoresSafeArea()
    }
}

#Preview {
    @Previewable @State var seen = false
    OnboardingContainerView(onboardingCheck: $seen)
}
