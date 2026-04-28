//
//  ProfileFormView.swift
//  Rep-Right
//

import SwiftUI

struct ProfileFormView: View {
    @Environment(UserProfileModel.self) private var profile
    @State private var isEditing: Bool = false
    
    var body: some View {
        @Bindable var profile = profile
        
        Form {
            Section {
                HStack {
                    // Profile Image placeholder
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange.opacity(0.7))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.name.isEmpty ? "New User" : profile.name)
                            .font(.title3.bold())
//                        Text("Rep-Right Member")
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }
            
            Section("Personal Information") {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Not Set", text: $profile.name)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .disabled(!isEditing)
                }
                
                Picker("Gender", selection: $profile.gender) {
                    ForEach(Genders.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .disabled(!isEditing)
                
                HStack {
                    Text("Age")
                    Spacer()
                    TextField("Not Set", value: $profile.age, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .disabled(!isEditing)
                }
                
                HStack {
                    Text("Weight (\(profile.unitSystem == .metric ? "kg" : "lbs"))")
                    Spacer()
                    TextField("Not Set", value: $profile.weight, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .disabled(!isEditing)
                }
                
                HStack {
                    Text("Height (\(profile.unitSystem == .metric ? "m" : "ft"))")
                    Spacer()
                    TextField("Not Set", value: $profile.height, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .disabled(!isEditing)
                }
            }
            .headerProminence(.increased)
            
            Section("Fitness Goals") {
                Picker("Fitness Level", selection: $profile.fitnessLevel) {
                    ForEach(FitnessLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .disabled(!isEditing)
                
                if isEditing {
                    Stepper(value: $profile.weeklyGoalDays, in: 1...7) {
                        Text("Weekly Goal: \(profile.weeklyGoalDays) days")
                    }
                } else {
                    HStack {
                        Text("Weekly Goal")
                        Spacer()
                        Text("\(profile.weeklyGoalDays) days")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .headerProminence(.increased)
            
            Section("Preferences") {
                Picker("Unit System", selection: $profile.unitSystem) {
                    ForEach(UnitSystem.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .disabled(!isEditing)
                
                Picker("AI Form Sensitivity", selection: $profile.modelSensitivity) {
                    ForEach(SensitivityLevels.allCases, id: \.self) { option in
                        Text(option.description).tag(option)
                    }
                }
                .disabled(!isEditing)
            }
            .headerProminence(.increased)
            
            Section {
                Button(role: .destructive, action: {
                    // Delete sessions action
                }) {
                    Text("Delete Recorded Sessions")
                }
                
                Button(role: .destructive, action: {
                    // Sign out action
                }) {
                    Text("Sign Out")
                }
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation {
                        isEditing.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileFormView()
            .environment(UserProfileModel())
    }
}
