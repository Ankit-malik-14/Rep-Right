//
//  UserProfile.swift
//  RepRightScreens
//
//  Created by Jugad on 09/03/26.
//

import SwiftUI

struct UserProfilee: View {
    
    enum Sex: String, CaseIterable {
        case notSet = "Not Set"
        case female = "Female"
        case male = "Male"
        case other = "Other"
    }
    
    enum ModelSenstivity: Double, CaseIterable {
        case Default = 3.0
        case Low = 1.5
        case High = 5.0
    }
    
    enum UnitSystem: String, CaseIterable {
        case metric = "Metric"
        case imperial = "Imperial"
    }
    
    enum AppTheme: String, CaseIterable {
        case Default = "Default"
        case Dark = "Dark"
        case Light = "Light"
    }
    
    @State var userFirstName: String = ""
    @State var userLastName: String = ""
    @State var userSex: Sex = .notSet
    @State var userAge: String = "18"
    @State var modelSensitiveness: Double = ModelSenstivity.Default.rawValue
    @State var selectedUnitSystem: String = UnitSystem.metric.rawValue
    @State var appTheme: String = AppTheme.Default.rawValue
    
    var body: some View {
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
                
                Section("Health Details"){
                    HStack(){
                        Text("First Name")
                        
                        TextField("Not Set", text: $userFirstName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack{
                        Text("Last Name")
                        
                        TextField("Not Set", text: $userLastName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Sex", selection: $userSex) {
                        ForEach(Sex.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    //height
                    //weight
                    HStack{
                        Text("Age")
                        
                        TextField("Not Set", text: $userAge)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section("Preference Detail"){
                    
                    Picker("Model Senstivity", selection: $modelSensitiveness) {
                        ForEach(ModelSenstivity.allCases, id: \.self) { option in
                            Text("\(option)").tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Units", selection: $selectedUnitSystem) {
                        ForEach(UnitSystem.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    //Notification
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
    }
}

#Preview {
    UserProfilee()
}
