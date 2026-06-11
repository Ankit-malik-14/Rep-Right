import SwiftUI

//struct OnboardingScreenView4: View {
//    @Environment(UserProfileModel.self) private var userProfile
//    @Binding var hasSeen: Bool
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 30) {
//            Text("Personalise your plan")
//                .font(.largeTitle.bold())
//                .padding(.top, 40)
//            
//            Text("What is your current fitness level?")
//                .font(.headline)
//            
//            VStack(spacing: 15) {
//                FitnessLevelCard(level: .beginner, title: "Beginner", description: "Just starting out or returning after a long break", isSelected: userProfile.fitnessLevel == .beginner) {
//                    userProfile.fitnessLevel = .beginner
//                }
//                
//                FitnessLevelCard(level: .intermediate, title: "Intermediate", description: "Consistent training for 6+ months", isSelected: userProfile.fitnessLevel == .intermediate) {
//                    userProfile.fitnessLevel = .intermediate
//                }
//                
//                FitnessLevelCard(level: .advanced, title: "Advanced", description: "Training regularly for 2+ years", isSelected: userProfile.fitnessLevel == .advanced) {
//                    userProfile.fitnessLevel = .advanced
//                }
//            }
//            
//            Text("How many days a week do you want to train?")
//                .font(.headline)
//                .padding(.top, 20)
//            
//            Picker("Days per week", selection: Bindable(userProfile).weeklyGoalDays) {
//                ForEach(1...7, id: \.self) { day in
//                    Text("\(day) days").tag(day)
//                }
//            }
//            .pickerStyle(.segmented)
//            
//            Spacer()
//            
//            Button {
//                hasSeen = true
//            } label: {
//                Text("Get Started")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(Color.orange)
//                    .cornerRadius(12)
//            }
//        }
//        .padding()
//    }
//}
//
//struct FitnessLevelCard: View {
//    let level: FitnessLevel
//    let title: String
//    let description: String
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(title)
//                        .font(.headline)
//                        .foregroundColor(isSelected ? .orange : .primary)
//                    Text(description)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.leading)
//                }
//                Spacer()
//                if isSelected {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.orange)
//                        .font(.title2)
//                } else {
//                    Image(systemName: "circle")
//                        .foregroundColor(.gray)
//                        .font(.title2)
//                }
//            }
//            .padding()
//            .background(isSelected ? Color.orange.opacity(0.1) : Color(UIColor.secondarySystemBackground))
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
//            )
//        }
//        .buttonStyle(.plain)
//    }
//}

import SwiftUI

struct OnboardingScreenView4: View {
    @Environment(UserProfileModel.self) private var userProfile
    @Binding var hasSeen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Personalise")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.black)
                Text("Your Plan")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.orange)
            }
            .padding(.top, 36)
            .padding(.horizontal, 28)
            .padding(.bottom, 32)

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    
                    // Motivational quote
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.orange)

                        Text("The only bad workout is the one that didn't happen.")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.black)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("— Every coach, ever")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    .padding(24)
                    .background(Color.orange.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal, 28)
                }
                .padding(.bottom, 40)
                    
                    // Fitness level section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("What is your current fitness level?")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 28)

                        VStack(spacing: 12) {
                            FitnessLevelCard(
                                level: .beginner,
                                title: "Beginner",
                                description: "Just starting out",
                                isSelected: userProfile.fitnessLevel == .beginner
                            ) { userProfile.fitnessLevel = .beginner }

                            FitnessLevelCard(
                                level: .intermediate,
                                title: "Intermediate",
                                description: "Consistent training for 6+ months",
                                isSelected: userProfile.fitnessLevel == .intermediate
                            ) { userProfile.fitnessLevel = .intermediate }
                        }
                        .padding(.horizontal, 28)
                    }

            }

            Spacer()
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.white.opacity(0), Color.white],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 32)

                Button {
                    hasSeen = true
                } label: {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.orange)
                        .clipShape(Capsule())
                        .padding(.horizontal, 28)
                }
                .padding(.bottom, 36)
                .background(Color.white)
            }
        }
        .background(Color.white)
    }
}

struct FitnessLevelCard: View {
    let level: FitnessLevel
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? .orange : .black)
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .orange : .gray)
                    .font(.title2)
            }
            .padding(16)
            .background(isSelected ? Color.orange.opacity(0.08) : Color.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingScreenView4(hasSeen: .constant(false))
        .environment(UserProfileModel())
}
