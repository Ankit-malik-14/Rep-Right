//
//  UserProfile.swift
//  RepRightScreens
//
//  Created by Jugad on 09/03/26.
//

import SwiftUI

struct UserProfilee: View {
    
    

    
    @State var userFirstName: String = ""
    @State var userLastName: String = ""
    @State var userSex: Genders = .male
    @State var userAge: String = "18"
    @State var modelSensitiveness: Double = SensitivityLevels.Medium.rawValue
    @State var selectedUnitSystem: String = UnitSystem.metric.rawValue
   
    
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
                        ForEach(Genders.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    //height
                    //weight
                    HStack{
                        TextField("Age", text: $userAge)
                    }
                }
                Section("Preference Detail"){
                    
                    Picker("Model Senstivity", selection: $modelSensitiveness) {
                        ForEach(SensitivityLevels.allCases, id: \.self) { option in
                            Text(option.description).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Units", selection: $selectedUnitSystem) {
                        ForEach(UnitSystem.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    
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
