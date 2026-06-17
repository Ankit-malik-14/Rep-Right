//
//  ActiveOnboardingView.swift
//  Rep-Right
//
//  Created by Antigravity on 15/06/26.
//

import SwiftUI

struct ActiveOnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    
    @Environment(UserProfileModel.self) private var profile
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(WeeklySchedules.self) private var weeklySchedules
    @Environment(Presets.self) private var presets
    
    @State private var viewModel = ActiveOnboardingViewModel()
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar (hidden on welcome screen)
                if viewModel.currentStep != .welcome {
                    progressHeader
                }
                
                // Active Screen content
                ZStack {
                    switch viewModel.currentStep {
                    case .welcome:
                        ActiveOnboardingWelcomeView()
                    case .measurements:
                        ActiveOnboardingMeasurementsView()
                            .environment(viewModel)
                    case .goals:
                        ActiveOnboardingGoalsView()
                            .environment(viewModel)
                    case .tutorial:
                        ActiveOnboardingTutorialView()
                            .environment(viewModel)
                            .environment(presets)
                    case .success:
                        ActiveOnboardingSuccessView(hasSeenOnboarding: $hasSeenOnboarding)
                            .environment(viewModel)
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Bottom control buttons
                bottomBar
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(viewModel.currentStep == .welcome ? "" : "Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStep != .welcome {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if let prev = ActiveOnboardingViewModel.OnboardingStep(rawValue: viewModel.currentStep.rawValue - 1) {
                                    viewModel.currentStep = prev
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .fontWeight(.bold)
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
        }
    }
    
    private var progressHeader: some View {
        HStack(spacing: 6) {
            ForEach(ActiveOnboardingViewModel.OnboardingStep.allCases.filter { $0 != .welcome }, id: \.self) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.currentStep.rawValue ? Color.orange : Color.orange.opacity(0.18))
                    .frame(height: 6)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            if viewModel.currentStep != .success {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if let next = ActiveOnboardingViewModel.OnboardingStep(rawValue: viewModel.currentStep.rawValue + 1) {
                            viewModel.currentStep = next
                        }
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isStepValid ? Color.orange : Color(.systemFill), in: Capsule())
                }
                .disabled(!isStepValid)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    private var isStepValid: Bool {
        switch viewModel.currentStep {
        case .welcome:
            return true
        case .measurements:
            return viewModel.isMeasurementsValid
        case .goals:
            return viewModel.isStep2Valid
        case .tutorial:
            return viewModel.selectedPreset != nil
        case .success:
            return true
        }
    }
}

// MARK: - Step 1: Measurements Setup
struct ActiveOnboardingMeasurementsView: View {
    @Environment(ActiveOnboardingViewModel.self) private var viewModel
    @FocusState private var focusedField: Int?
    
    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("A Little About You")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    Text("Enter your weight and height to establish baseline metabolic and calorie estimates.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)
                
                // Units selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("Unit System")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    
                    Picker("Unit System", selection: $viewModel.unitSystem) {
                        Text("Metric (kg, cm)").tag(UnitSystem.metric)
                        Text("Imperial (lbs, ft)").tag(UnitSystem.imperial)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.unitSystem) { _, newSystem in
                        viewModel.handleUnitChange(to: newSystem)
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                
                // Height and Weight Fields
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weight")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                TextField("70", value: $viewModel.weight, format: .number)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: 0)
                                    .font(.title2.bold())
                                    .frame(width: 80)
                                Text(viewModel.unitSystem == .metric ? "kg" : "lbs")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Divider().frame(height: 40)
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Height")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                TextField(viewModel.unitSystem == .metric ? "1.70" : "5.6", value: $viewModel.height, format: .number)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: 1)
                                    .font(.title2.bold())
                                    .frame(width: 80)
                                Text(viewModel.unitSystem == .metric ? "meters" : "feet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Step 2: Training Goals
struct ActiveOnboardingGoalsView: View {
    @Environment(ActiveOnboardingViewModel.self) private var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Weekly Motivation")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    Text("Set a comfortable starting point to keep yourself motivated. Your weekly goals will naturally adjust based on your active days.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)
                
                VStack(spacing: 20) {
                    // Stepper: Active Days
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weekly Target")
                                .font(.body.bold())
                            Text("Days per week you aim to train")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Stepper(value: $viewModel.weeklyGoalDays, in: 1...7) {
                            Text("\(viewModel.weeklyGoalDays) days")
                                .font(.headline)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    
                    // Stepper: Calorie Goal
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Move Goal")
                                .font(.body.bold())
                            Text("Calorie expectation per active day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Stepper(value: $viewModel.dailyCalorieBurn, in: 100...2000, step: 50) {
                            Text("\(Int(viewModel.dailyCalorieBurn)) kcal")
                                .font(.headline)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                }
                
                // Dynamic Output Box
                VStack(alignment: .leading, spacing: 8) {
                    Label("Weekly Active Burn Target", systemImage: "flame.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                    Text("\(Int(viewModel.weeklyCalorieBurn)) Kcal / Week")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text("Based on your target of \(viewModel.weeklyGoalDays) active days multiplying your \(Int(viewModel.dailyCalorieBurn)) Kcal daily move expectation.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.18), lineWidth: 1)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
    }
}

// MARK: - Step 3: Monday Tutorial Setup
struct ActiveOnboardingTutorialView: View {
    @Environment(ActiveOnboardingViewModel.self) private var viewModel
    @Environment(Presets.self) private var presets
    
    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Schedule Monday")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    Text("Rep-Right rotates muscle groups smartly. Schedule your first workout on Monday to learn the layout.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)
                
                // Tutorial card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("MONDAY")
                            .font(.caption.bold())
                            .foregroundStyle(.orange)
                        Spacer()
                    }
                    
                    if let preset = viewModel.selectedPreset {
                        // Show selected preset
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "dumbbell.fill")
                                    .foregroundStyle(.orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(preset.name)
                                    .font(.headline)
                                Text("\(preset.estTime) mins • \(preset.calories) kcal")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Change") {
                                viewModel.showPresetPicker = true
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(.orange)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    } else {
                        // Empty tutorial card
                        Button {
                            viewModel.showPresetPicker = true
                        } label: {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "plus")
                                        .font(.title3.bold())
                                        .foregroundStyle(.orange)
                                }
                                Text("Tap to schedule a workout preset")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 24)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(style: .init(dash: [4, 4]))
                                    .foregroundStyle(Color.orange.opacity(0.4))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        .sheet(isPresented: $viewModel.showPresetPicker) {
            ActiveOnboardingPresetPicker()
                .environment(viewModel)
                .environment(presets)
        }
    }
}

// MARK: - Mini Preset Picker Sheet
struct ActiveOnboardingPresetPicker: View {
    @Environment(ActiveOnboardingViewModel.self) private var viewModel
    @Environment(Presets.self) private var presets
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // Pick the first 3 curated presets to keep it simple
                    ForEach(Array(presets.presets.prefix(3))) { preset in
                        Button {
                            viewModel.selectPreset(preset)
                        } label: {
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.12))
                                    .frame(width: 54, height: 54)
                                    .overlay {
                                        Image(systemName: "dumbbell.fill").foregroundStyle(.orange)
                                    }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preset.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("\(preset.estTime) mins • \(preset.calories) kcal")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        viewModel.showPresetPicker = false
                    }
                    .foregroundStyle(.orange)
                }
            }
        }
    }
}

// MARK: - Step 4: Onboarding Success
struct ActiveOnboardingSuccessView: View {
    @Binding var hasSeenOnboarding: Bool
    
    @Environment(ActiveOnboardingViewModel.self) private var viewModel
    @Environment(UserProfileModel.self) private var profile
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(WeeklySchedules.self) private var weeklySchedules
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Success animations / graphics
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.orange)
                    }
                    
                    Text("Ready to Move!")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    Text("Your training profile is set up. Let's start building your workout streaks.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 24)
                
                // Summary Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Your Settings Summary")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 12) {
                        summaryRow(title: "Units", value: viewModel.unitSystem == .metric ? "Metric" : "Imperial")
                        Divider()
                        summaryRow(title: "Weight", value: "\(Int(viewModel.weight)) \(viewModel.unitSystem == .metric ? "kg" : "lbs")")
                        Divider()
                        summaryRow(title: "Weekly Goal", value: "\(viewModel.weeklyGoalDays) workout days")
                        Divider()
                        summaryRow(title: "Monday", value: viewModel.selectedPreset?.name ?? "Scheduled")
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                
                // Complete Action Button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.saveAndComplete(
                            profile: profile,
                            summaryManager: summaryManager,
                            weeklySchedules: weeklySchedules
                        )
                        hasSeenOnboarding = true
                    }
                } label: {
                    Text("Start Training")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange, in: Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Welcome / Features View
struct ActiveOnboardingWelcomeView: View {
    struct Feature {
        let icon: String
        let title: String
        let description: String
    }

    let features: [Feature] = [
        Feature(
            icon: "figure.strengthtraining.traditional",
            title: "Your Personal AI Coach",
            description: "Get real-time feedback and custom workout plans tailored to your body and goals."
        ),
        Feature(
            icon: "camera.viewfinder",
            title: "Perfect Your Form",
            description: "Helps reduce risk of injuries with instant alerts when your posture needs adjustment."
        ),
        Feature(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "See detailed metrics, streaks, and performance summaries after every session."
        ),
        Feature(
            icon: "calendar.badge.checkmark",
            title: "Plan Your Success",
            description: "Schedule your splits and track your consistency with detailed summaries."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome to")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("Rep-Right")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.orange)
                }
                .padding(.top, 40)
                .padding(.horizontal, 4)
                .padding(.bottom, 40)

                // Feature rows
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(features, id: \.title) { feature in
                        HStack(alignment: .top, spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.12))
                                    .frame(width: 52, height: 52)
                                Image(systemName: feature.icon)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(.orange)
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text(feature.title)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(.primary)
                                Text(feature.description)
                                    .font(.system(size: 15))
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
