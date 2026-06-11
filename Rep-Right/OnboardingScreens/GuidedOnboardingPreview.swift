import SwiftUI

struct GuidedOnboardingPreviewHost: View {
    @State private var hasCompletedPreview = false
    
    var body: some View {
        Group {
            if hasCompletedPreview {
                HomeView()
            } else {
                GuidedOnboardingFlow {
                    hasCompletedPreview = true
                }
            }
        }
    }
}

private struct OnboardingPreferencesDraft {
    var unitSystem: UnitSystem
    var weight: Double
    var fitnessLevel: FitnessLevel
    var modelSensitivity: SensitivityLevels
    var weeklyGoalDays: Int
    var dailyCalorieGoal: Double
    
    init(profile: UserProfileModel, summaryManager: WorkoutSummaryManager) {
        self.unitSystem = profile.unitSystem
        self.weight = profile.weight
        self.fitnessLevel = profile.fitnessLevel
        self.modelSensitivity = profile.modelSensitivity
        self.weeklyGoalDays = profile.weeklyGoalDays
        self.dailyCalorieGoal = summaryManager.dailyCalorieGoal
    }
}

struct GuidedOnboardingFlow: View {
    @Environment(UserProfileModel.self) private var profile
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    
    let onFinish: () -> Void
    
    @State private var currentPage = 0
    @State private var draft: OnboardingPreferencesDraft?
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                
                TabView(selection: $currentPage) {
                    overviewPage
                        .tag(0)
                    
                    setupPage
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                bottomBar
            }
        }
        .onAppear {
            draft = OnboardingPreferencesDraft(profile: profile, summaryManager: summaryManager)
        }
    }
    
    private var topBar: some View {
        HStack {
            Text("Rep-Right")
                .font(.headline.weight(.semibold))
            
            Spacer()
            
            Text(currentPage == 0 ? "Overview" : "Setup")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }
    
    private var overviewPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("A clearer way to train at home")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Rep-Right helps you plan workouts, train with live form support, and understand your progress in one place.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                overviewSection(
                    title: "What you can do here",
                    lines: [
                        "Follow structured presets and browse individual exercises.",
                        "Use camera-assisted feedback for supported movements.",
                        "Plan your week with recovery-aware workout suggestions.",
                        "Review calories, activity, streaks, and form trends after training."
                    ]
                )
                
                overviewSection(
                    title: "How it helps",
                    lines: [
                        "The workout tab gives you a more guided starting point instead of choosing everything manually.",
                        "The assistance flow helps catch posture issues during supported exercises.",
                        "The summary views turn completed workouts into useful feedback for future sessions."
                    ]
                )
                
                overviewSection(
                    title: "What we’ll set up next",
                    lines: [
                        "A few training preferences that help tune calorie estimates, goal suggestions, and coaching behavior.",
                        "Only app-related setup is collected here. Since this flow is not tied to account signup, we are not asking for personal identity details."
                    ]
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    private func overviewSection(title: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(lines, id: \.self) { line in
                    Text(line)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .appCardStyle()
        }
    }
    
    private var setupPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tune the app to you")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("These values are used inside the app to improve calculations and recommendations. Weight is specifically used for calorie estimation.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                if let draftBinding = draftBinding {
                    VStack(spacing: 16) {
                        setupCard(
                            title: "Calculation Baseline",
                            footnote: "Weight helps the app estimate calories more accurately, and units keep measurements consistent across the app.",
                            rows: [
                                AnyView(unitPicker(draftBinding.unitSystem)),
                                AnyView(numberField(title: draftBinding.unitSystem.wrappedValue == .metric ? "Weight (kg)" : "Weight (lbs)", value: draftBinding.weight))
                            ]
                        )
                        
                        setupCard(
                            title: "Training Preferences",
                            footnote: "These settings influence workout planning and how sensitive the form guidance should feel during supported exercises.",
                            rows: [
                                AnyView(fitnessLevelPicker(draftBinding.fitnessLevel)),
                                AnyView(sensitivityPicker(draftBinding.modelSensitivity)),
                                AnyView(goalStepper(title: "Weekly workout goal", suffix: "days", value: draftBinding.weeklyGoalDays, range: 1...7)),
                                AnyView(goalNumberRow(title: "Daily calorie goal", suffix: "kcal", value: draftBinding.dailyCalorieGoal))
                            ]
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
    }
    
    private func setupCard(title: String, footnote: String, rows: [AnyView]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    row
                    if index < rows.count - 1 {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            }
            
            Text(footnote)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    private func unitPicker(_ binding: Binding<UnitSystem>) -> some View {
        Picker("Units", selection: binding) {
            ForEach(UnitSystem.allCases, id: \.self) { unit in
                Text(unit.rawValue).tag(unit)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }
    
    private func fitnessLevelPicker(_ binding: Binding<FitnessLevel>) -> some View {
        Picker("Fitness level", selection: binding) {
            ForEach(FitnessLevel.allCases, id: \.self) { level in
                Text(level.rawValue).tag(level)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }
    
    private func sensitivityPicker(_ binding: Binding<SensitivityLevels>) -> some View {
        Picker("Model sensitivity", selection: binding) {
            ForEach(SensitivityLevels.allCases, id: \.self) { level in
                Text(level.description).tag(level)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }
    
    private func numberField(title: String, value: Binding<Double>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", value: value, format: .number)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    private func goalStepper(title: String, suffix: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        Stepper(value: value, in: range) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value.wrappedValue) \(suffix)")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    private func goalNumberRow(title: String, suffix: String, value: Binding<Double>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", value: value, format: .number)
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
                .foregroundStyle(.secondary)
            Text(suffix)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    private var bottomBar: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.orange : Color.orange.opacity(0.18))
                        .frame(width: index == currentPage ? 22 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }
            
            Button(action: advance) {
                Text(currentPage == 1 ? "Start Exploring" : "Continue")
            }
            .buttonStyle(AppPrimaryButtonStyle())
            
            if currentPage == 1 {
                Button("Back") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentPage = 0
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(.bar)
    }
    
    private func advance() {
        if currentPage == 0 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentPage = 1
            }
            return
        }
        
        applyDraft()
        onFinish()
    }
    
    private func applyDraft() {
        guard let draft else { return }
        profile.unitSystem = draft.unitSystem
        profile.weight = draft.weight
        profile.fitnessLevel = draft.fitnessLevel
        profile.modelSensitivity = draft.modelSensitivity
        profile.weeklyGoalDays = draft.weeklyGoalDays
        summaryManager.dailyCalorieGoal = max(100, draft.dailyCalorieGoal)
        summaryManager.currentUserWeight = profile.weightInKilograms
    }
    
    private var draftBinding: Binding<OnboardingPreferencesDraft>? {
        guard draft != nil else { return nil }
        return Binding(
            get: { draft ?? OnboardingPreferencesDraft(profile: profile, summaryManager: summaryManager) },
            set: { draft = $0 }
        )
    }
}

#Preview {
    GuidedOnboardingPreviewHost()
        .environment(Presets())
        .environment(CustomPresetsDummyData())
        .environment(Exercises())
        .environment(WeeklySchedules())
        .environment(WorkoutSummaryManager())
        .environment(UserProfileModel())
}
