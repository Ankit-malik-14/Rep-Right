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
                        ForEach(Genders.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    //height
                    //weight
                    HStack{
                        Text("Age")
                        
                        TextField("Not Set", text: $userAge)
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
    }
}

#Preview {
    UserProfilee()
}
