//
//  ProfileFormView.swift
//  Rep-Right
//

import SwiftUI


struct ProfileFormView: View {
    @Environment(UserProfileModel.self) private var profile
    
    var body: some View {
        @Bindable var profile = profile
        //NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange.opacity(0.7))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.name)
                                .font(.title3.bold())
                            Text("Rep-Right Member")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                Section("Personal Information") {
                    TextField("Name", text: $profile.name)
                        .autocorrectionDisabled()
                    
                    HStack {
                        Label("Weight", systemImage: "scalemass.fill")
                        Spacer()
                        TextField("kg", value: $profile.weight, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                }
                .headerProminence(.increased)
                
                Section("Preferences") {
                    Label("Notifications", systemImage: "bell.fill")
                    Label("Units", systemImage: "ruler.fill")
                    Label("Appearance", systemImage: "paintbrush.fill")
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Profile")
        //}
    }
}

#Preview {
    ProfileFormView()
        .environment(UserProfileModel())
}
