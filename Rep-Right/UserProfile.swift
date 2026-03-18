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
                HStack(){
                    Spacer()
                    VStack{
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.orange)
                            .font(.system(size: 180))
                        Text("UserName")
                            .font(.title)
                    }
                    Spacer()
                }
                Section("Health Details"){
                    TextField("First Name", text: $userFirstName)
                    
                    TextField("Last Name", text: $userLastName)
                    
                    Picker("Sex", selection: $userSex) {
                        ForEach(Sex.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    //height
                    //weight
                    TextField("Age", text: $userAge)
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
            //            Button {
            //                //delete session
            //            } label: {
            //                Text("Delete Recorded Sessions")
            //            }
            //            Button {
            //                // user sign out
            //            } label: {
            //                Text("Sign Out")
            //            }.buttonBorderShape(.roundedRectangle(radius: 5))
    }
}

#Preview {
    UserProfilee()
}
