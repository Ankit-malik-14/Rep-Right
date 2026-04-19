/* DEPRECATED: Replaced by ProfileFormView which uses @Bindable MVVM architecture.
//
//  UserProfile.swift
//  RepRightScreens
//

import SwiftUI

struct UserProfileView: View {
    // Fetched from DataModel: user profile data from DummyUserProfiles
    var userProfile: UserProfile = DummyUserProfiles().user
    
    @State var isDisabled: Bool = true
    // Fetched from DataModel: pre-populated from UserProfile.name
    @State var userFirstName: String = ""
    // Fetched from DataModel: pre-populated from UserProfile.gender
    @State var userSex: Genders = .male
    // Fetched from DataModel: pre-populated from UserProfile.age
    @State var userAge: Int = 0
    // Fetched from DataModel: pre-populated from UserProfile.modelSensitivity
    @State var modelSensitiveness: Double = SensitivityLevels.Medium.rawValue
    // Fetched from DataModel: pre-populated from UserProfile.unitSystem
    @State var selectedUnitSystem: String = UnitSystem.metric.rawValue
    // Fetched from DataModel: pre-populated from UserProfile.weight
    @State var weight: Double = 0.0
    // Fetched from DataModel: pre-populated from UserProfile.height
    @State var height: Double = 0.0
    
    var body: some View {
        VStack{
            
            Form{
                Section{
                    VStack(alignment: .center) {
                        Image("UserImage")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    }.frame(maxWidth: .infinity)
                        .padding()
                }
                
                Section("Preference Detail"){
                    HStack(){
                        Text("Name")
                        
                        TextField("Not Set", text: $userFirstName)
                            .multilineTextAlignment(.trailing)
                            .disabled(isDisabled)
                    }
                    
                    Picker("Sex", selection: $userSex) {
                        ForEach(Genders.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(isDisabled)
                    HStack{
                        Text("Weight")
                        TextField("Not Set", value: $weight, format: .number)
                            .multilineTextAlignment(.trailing)
                            .disabled(isDisabled)
                    }
                    HStack{
                        Text("Height")
                        TextField("Not Set", value: $height, format: .number)
                            .multilineTextAlignment(.trailing)
                            .disabled(isDisabled)
                    }
                    HStack{
                        Text("Age")
                        
                        TextField("Not Set", value: $userAge, format: .number)
                            .multilineTextAlignment(.trailing)
                            .disabled(isDisabled)
                    }
                }
                Section("Preferences"){
                    
                    Picker("Model Senstivity", selection: $modelSensitiveness) {
                        ForEach(SensitivityLevels.allCases, id: \.self) { option in
                            Text(option.description).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(isDisabled)
                    Picker("Units", selection: $selectedUnitSystem) {
                        ForEach(UnitSystem.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(isDisabled)
                    
                }
                Section {
                    Button(action: {
                        // Delete sessions
                    }) {
                        Text("Delete Recorded Sessions")
                    }
                    Button(role: .destructive, action: {
                        // Sign out
                    }) {
                        Text("Sign Out")
                    }
                }
            }
            .toolbar {
                ToolbarItem(id: "Save", placement: .topBarTrailing) {
                    Button(isDisabled ? "Edit" : "Save") {
                        isDisabled.toggle()
                    }
                }
            }
        }
        .onAppear {
            // Fetched from DataModel: populate form fields from UserProfile model
            userFirstName = userProfile.name
            userSex = userProfile.gender
            userAge = userProfile.age
            weight = Double(userProfile.weight)
            height = userProfile.height
            modelSensitiveness = userProfile.modelSensitivity.rawValue
            selectedUnitSystem = userProfile.unitSystem.rawValue
        }
    }
}

#Preview {
    NavigationStack{
        UserProfileView()
    }
}
*/
