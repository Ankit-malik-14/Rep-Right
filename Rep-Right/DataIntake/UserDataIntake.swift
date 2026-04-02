//
//  UserDataIntake.swift
//  Rep_Right
//
//  Created by Mayurakshi Das on 01/04/26.
//

import SwiftUI
import Foundation
import Observation


enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    var id: Self{self}
}

@Observable
class UserProfileStore {
    var isMetric: Bool = false
    var gender: Gender = .male
    var age: String = ""
    
    // Internal values always kept in Metric for consistency
    var heightInCm: Double = 0.0
    var weightInKg: Double = 0.0
    
    // Computed property for Height
    var heightDisplay: String {
        get {
            if isMetric {
                return heightInCm > 0 ? String(format: "%.0f", heightInCm) : ""
            } else {
                return heightInCm > 0 ? String(format: "%.1f", heightInCm / 2.54) : ""
            }
        }
        set {
            let val = Double(newValue) ?? 0.0
            heightInCm = isMetric ? val : val * 2.54
        }
    }
    
    // Computed property for Weight
    var weightDisplay: String {
        get {
            if isMetric {
                return weightInKg > 0 ? String(format: "%.1f", weightInKg) : ""
            } else {
                return weightInKg > 0 ? String(format: "%.1f", weightInKg * 2.20462) : ""
            }
        }
        set {
            let val = Double(newValue) ?? 0.0
            weightInKg = isMetric ? val : val / 2.20462
        }
    }
}


struct UserDataIntake: View {
    // This is our separate storage instance
    @State private var store = UserProfileStore()

    var body: some View {
        VStack {
            Text("Personalize Your Plan")
                .font(.largeTitle.bold())
                .padding()

            Picker("Unit System", selection: $store.isMetric) {
                Text("Imperial").tag(false)
                Text("Metric").tag(true)
            }
            .pickerStyle(.segmented)
            .padding()

            // Pass the store into subviews
                Form{
                    InputSection(store: store)
                }.background(.white)
                .scrollDisabled(true)
            
        }.padding(.vertical)
    }
}
struct InputSection: View {
    // Bind directly to the separate store
    @Bindable var store: UserProfileStore
    
    var body: some View {
        Section {
            Picker("Gender", selection: $store.gender) {
                ForEach(Gender.allCases) { g in
                    Text(g.rawValue).tag(g)
                }
            }
            
            HStack {
                Text("Age")
                Spacer()
                TextField("Age", text: $store.age)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
            }
            
            HStack {
                Text("Height (\(store.isMetric ? "cm" : "in"))")
                Spacer()
                TextField(store.isMetric ? "170" : "67", text: $store.heightDisplay)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
            }
            
            HStack {
                Text("Weight (\(store.isMetric ? "kg" : "lbs"))")
                Spacer()
                TextField(store.isMetric ? "70" : "154", text: $store.weightDisplay)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
            }
        }
    }
}

#Preview {
    UserDataIntake()
}
