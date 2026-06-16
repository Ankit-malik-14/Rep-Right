import SwiftUI

struct OnboardingScreenView4: View {
    @Environment(UserProfileModel.self) private var userProfile
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    let onComplete: () -> Void
    
    @State private var weightInput: Double = 70
    @State private var weeklyCalorieGoalInput: Double = 400
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Personalise")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.black)
                        Text("Your Plan")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.orange)
                        
                        Text("The only bad workout is the one that didn't happen.")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.black)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Set weekly benchmark for your jounrey")
                            .font(.system(size: 15))
                            .foregroundStyle(.gray)
                    }
                    .padding(24)
                    .background(Color.orange.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Calculation Inputs")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Weight (kg)")
                                Spacer()
                                TextField("0", value: $weightInput, format: .number)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            HStack {
                                Text("Weekly Calorie Goal")
                                Spacer()
                                TextField("400", value: $weeklyCalorieGoalInput, format: .number)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.numberPad)
                                    .foregroundStyle(.secondary)
                                Text("kcal")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Calorie Goal Guide")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Use your weekly goal as a motivating benchmark, not a strict requirement.")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                            
                            Text("For context:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text("Walking 1 km usually burns about 45-70 kcal.")
                            Text("A light 30-minute workout often burns around 150-250 kcal.")
                            Text("A harder 45-60 minute session may burn around 300-500 kcal.")
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(18)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        }
                    }
                    
                    Text("These are defaults you can change later from the app. Nothing here is tied to account creation.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button {
                    applyInputs()
                    onComplete()
                } label: {
                    Text("Get Started")
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .background(.bar)
            }
        }
        .onAppear {
            userProfile.unitSystem = .metric
            weightInput = userProfile.weightInKilograms
            weeklyCalorieGoalInput = summaryManager.dailyCalorieGoal
        }
    }
    
    private func applyInputs() {
        userProfile.unitSystem = .metric
        userProfile.weight = max(1, weightInput)
        summaryManager.currentUserWeight = userProfile.weightInKilograms
        summaryManager.dailyCalorieGoal = max(1, weeklyCalorieGoalInput)
    }
}

#Preview {
    OnboardingScreenView4(onComplete: {})
        .environment(UserProfileModel())
        .environment(WorkoutSummaryManager())
}
