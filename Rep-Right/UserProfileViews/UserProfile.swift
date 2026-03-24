//
//  UserProfile.swift
//  RepRightScreens
//
//  Created by Jugad on 09/03/26.
//

import SwiftUI

struct UserProfileView: View {
    @State var isDisabled: Bool = true
    @State var userFirstName: String = ""
    @State var userSex: Genders = .male
    @State var userAge: Int = 0
    @State var modelSensitiveness: Double = SensitivityLevels.Medium.rawValue
    @State var selectedUnitSystem: String = UnitSystem.metric.rawValue
    @State var weight: Double = 0.0
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
    }
}

#Preview {
    NavigationStack{
        UserProfileView()
    }
}
