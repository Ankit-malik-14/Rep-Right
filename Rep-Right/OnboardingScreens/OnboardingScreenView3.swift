import SwiftUI

struct OnboardingScreenView3: View {
    var body: some View {
        VStack {
            MetricsView()
            
            Spacer()
            //Add over here the schedule part one
            
            VStack(spacing: 8) {
                Text("Plan Your Success")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                
                Text("Schedule your splits and track your\nconsistency with detailed summaries.")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("14")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.orange)
                        Text("Exercises")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    VStack {
                        Text("5d")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.orange)
                        Text("Streak")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    VStack {
                        Text("4.2k")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.orange)
                        Text("Cals")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            Spacer()
            Button {
                //
            } label: {
                continueButtonView()
            }

        }
    }
}
#Preview
    {
    OnboardingScreenView3()
}
