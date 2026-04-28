//
//  ProfileFormView.swift
//  Rep-Right
//

import SwiftUI

// MARK: - Custom Label Style for Native Settings Look
struct SettingsIconLabelStyle: LabelStyle {
    var backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 14) {
            configuration.icon
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            
            configuration.title
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Main View
struct ProfileFormView: View {
    @Environment(UserProfileModel.self) private var profile
    @State private var isEditing: Bool = false
    
    var body: some View {
        @Bindable var profile = profile
        
        Form {
            // MARK: Header Section
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 85, height: 85)
                        .foregroundStyle(Color(uiColor: .systemGray4))
                    
                    VStack(spacing: 4) {
                        Text(profile.name.isEmpty ? "New User" : profile.name)
                            .font(.title2.weight(.semibold))
                        
                        Text("Rep-Right Member")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                .padding(.bottom, 6)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets()) // Removes default padding for centered look
            
            // MARK: Personal Information
            Section("Personal Information") {
                HStack {
                    Label("Name", systemImage: "person.text.rectangle.fill")
                        .labelStyle(SettingsIconLabelStyle(backgroundColor: .blue))
                    Spacer()
                    TextField("Not Set", text: $profile.name)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(isEditing ? .primary : .secondary)
                        .autocorrectionDisabled()
                        .disabled(!isEditing)
                }
                
                Picker(selection: $profile.gender) {
                    ForEach(Genders.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                } label: {
                    Label("Gender", systemImage: "person.2.fill")
                        .labelStyle(SettingsIconLabelStyle(backgroundColor: .blue))
                }
                .disabled(!isEditing)
                
                HStack {
                    Label("Age", systemImage: "calendar")
                        .labelStyle(SettingsIconLabelStyle(backgroundColor: .red))
                    Spacer()
                    TextField("Not Set", value: $profile.age, format: .number)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(isEditing ? .primary : .secondary)
                        .keyboardType(.numberPad)
                        .disabled(!isEditing)
                }
                
                HStack {
                    Label("Weight (\(profile.unitSystem == .metric ? "kg" : "lbs"))", systemImage: "scalemass.fill")
                        .labelStyle(SettingsIconLabelStyle(backgroundColor: .green))
                    Spacer()
                    TextField("Not Set", value: $profile.weight, format: .number)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(isEditing ? .primary : .secondary)
                        .keyboardType(.decimalPad)
                        .disabled(!isEditing)
                }
                
                HStack {
                    Label("Height (\(profile.unitSystem == .metric ? "cm" : "ft"))", systemImage: "ruler.fill")
                        .labelStyle(SettingsIconLabelStyle(backgroundColor: .cyan))
                    Spacer()
                    TextField("Not Set", value: $profile.height, format: .number)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(isEditing ? .primary : .secondary)
                        .keyboardType(.decimalPad)
                        .disabled(!isEditing)
                }
            }
            
            // MARK: Fitness Goals
            Section("Fitness Goals") {
                Picker(selection: $profile.fitnessLevel) {
                    ForEach(FitnessLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                } label: {
                    Label("Fitness Level", systemImage: "figure.run")
                        .labelStyle(SettingsIconLabelStyle(backgroundColor: .orange))
                }
                .disabled(!isEditing)
                
                if isEditing {
                    Stepper(value: $profile.weeklyGoalDays, in: 1...7) {
                        Label("Weekly Goal: \(profile.weeklyGoalDays) days", systemImage: "target")
                            .labelStyle(SettingsIconLabelStyle(backgroundColor: .pink))
                    }
                } else {
                    HStack {
                        Label("Weekly Goal", systemImage: "target")
                            .labelStyle(SettingsIconLabelStyle(backgroundColor: .pink))
                        Spacer()
                        Text("\(profile.weeklyGoalDays) days")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // MARK: Preferences
            Section("Preferences") {
                Picker(selection: $profile.unitSystem) {
                    ForEach(UnitSystem.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                } label: {
                    Label("Unit System", systemImage: "switch.2")
                        .labelStyle(SettingsIconLabelStyle(backgroundColor: .gray))
                }
                .disabled(!isEditing)
                
                Picker(selection: $profile.modelSensitivity) {
                    ForEach(SensitivityLevels.allCases, id: \.self) { option in
                        Text(option.description).tag(option)
                    }
                } label: {
                    Label("AI Form Sensitivity", systemImage: "brain.head.profile")
                        .labelStyle(SettingsIconLabelStyle(backgroundColor: .purple))
                }
                .disabled(!isEditing)
            }
            
            // MARK: Destructive Actions
            Section {
                Button(role: .destructive, action: {
                    // Delete sessions action
                }) {
                    Text("Delete Recorded Sessions")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Button(role: .destructive, action: {
                    // Sign out action
                }) {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline) // Standard for nested settings views
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation {
                        isEditing.toggle()
                    }
                }
                .fontWeight(isEditing ? .bold : .regular)
            }
        }
    }
}

/*// MARK: - Mocks for Preview Completeness
@Observable
class UserProfileModel {
    var name: String = "John Doe"
    var gender: Genders = .male
    var age: Int? = 28
    var weight: Double? = 82.5
    var height: Double? = 180.0
    var fitnessLevel: FitnessLevel = .intermediate
    var weeklyGoalDays: Int = 4
    var unitSystem: UnitSystem = .metric
    var modelSensitivity: SensitivityLevels = .medium
}

enum Genders: String, CaseIterable {
    case notSet = "Not Set"
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

enum FitnessLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

enum UnitSystem: String, CaseIterable {
    case metric = "Metric"
    case imperial = "Imperial"
}

enum SensitivityLevels: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var description: String { self.rawValue }
}
 */

#Preview {
    NavigationStack {
        ProfileFormView()
            .environment(UserProfileModel())
    }
}
