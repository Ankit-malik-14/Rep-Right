import SwiftUI

struct OnboardingScreenView4: View {
    @Environment(UserProfileModel.self) private var userProfile
    @Binding var hasSeen: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Personalise your plan")
                .font(.largeTitle.bold())
                .padding(.top, 40)
            
            Text("What is your current fitness level?")
                .font(.headline)
            
            VStack(spacing: 15) {
                FitnessLevelCard(level: .beginner, title: "Beginner", description: "Just starting out or returning after a long break", isSelected: userProfile.fitnessLevel == .beginner) {
                    userProfile.fitnessLevel = .beginner
                }
                
                FitnessLevelCard(level: .intermediate, title: "Intermediate", description: "Consistent training for 6+ months", isSelected: userProfile.fitnessLevel == .intermediate) {
                    userProfile.fitnessLevel = .intermediate
                }
                
                FitnessLevelCard(level: .advanced, title: "Advanced", description: "Training regularly for 2+ years", isSelected: userProfile.fitnessLevel == .advanced) {
                    userProfile.fitnessLevel = .advanced
                }
            }
            
            Text("How many days a week do you want to train?")
                .font(.headline)
                .padding(.top, 20)
            
            Picker("Days per week", selection: Bindable(userProfile).weeklyGoalDays) {
                ForEach(1...7, id: \.self) { day in
                    Text("\(day) days").tag(day)
                }
            }
            .pickerStyle(.segmented)
            
            Spacer()
            
            Button {
                hasSeen = true
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
        }
        .padding()
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
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .orange : .primary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? Color.orange.opacity(0.1) : Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
