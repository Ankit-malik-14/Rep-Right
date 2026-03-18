//
//  UserProfile.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-17.
//

import SwiftUI

struct UserProfileView: View {
    var userData: UserProfile
    
    var body: some View {
        let imageName = userData.profilePicture ?? "DefaultProfilePicture"
        Form {
            Section{
                VStack(alignment: .center) {
                    Image(imageName)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                }.frame(maxWidth: .infinity)
                    .padding()
            }
            Section{
                Text(userData.name)
                Text("\(userData.age)")
                Text(userData.gender.rawValue)
                Text("\(userData.weight) \(userData.unitSystem != .metric ? "lbs" : "kg")")
                Text("\(userData.height.description) \(userData.unitSystem == .metric ? "m" : "foot")")
            }
            Section{
                let sensitivityText: String = {
                    switch userData.modelSensitivity {
                    case .High: return "High"
                    case .Medium: return "Medium"
                    case .Low: return "Low"
                    }
                }()
                Text(sensitivityText)
            }
            
        }
            
    }
}

#Preview {
    UserProfileView(userData: DummyUserProfiles().user)
}
