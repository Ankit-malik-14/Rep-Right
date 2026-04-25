//
//  UserDataIntake.swift
//  Rep_Right
//
//  Created by Mayurakshi Das on 01/04/26.
//

import SwiftUI
import Foundation

// Backward compatibility aliases to resolve any local scope naming issues
typealias UserProfileStore = UserProfileModel
typealias Gender = Genders


/* DEPRECATED: UserProfileStore is deprecated. Replaced by the native @Observable UserProfileModel to enforce a single source of truth.
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
*/

// UPDATED: Now uses UserProfileModel as the single source of truth.
struct UserDataIntake: View {
    @Environment(UserProfileModel.self) private var store

    var body: some View {
        @Bindable var localStore = store
        VStack {
            Text("Personalize Your Plan")
                .font(.largeTitle.bold())
                .padding()

            Picker("Unit System", selection: $localStore.unitSystem) {
                Text("Imperial").tag(UnitSystem.imperial)
                Text("Metric").tag(UnitSystem.metric)
            }
            .pickerStyle(.segmented)
            .padding()

            Form{
                InputSection(store: store)
            }.background(.white)
            .scrollDisabled(true)
            
        }.padding(.vertical)
    }
}

struct InputSection: View {
    @Bindable var store: UserProfileModel
    
    var body: some View {
        Section {
            Picker("Gender", selection: $store.gender) {
                ForEach(Genders.allCases, id: \.self) { g in
                    Text(g.rawValue).tag(g)
                }
            }
            
            HStack {
                Text("Age")
                Spacer()
                TextField("Age", value: $store.age, format: .number)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
            }
            
            HStack {
                Text("Height (\(store.unitSystem == .metric ? "m" : "ft"))")
                Spacer()
                TextField(store.unitSystem == .metric ? "1.7" : "5.6", value: $store.height, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
            }
            
            HStack {
                Text("Weight (\(store.unitSystem == .metric ? "kg" : "lbs"))")
                Spacer()
                TextField(store.unitSystem == .metric ? "70" : "154", value: $store.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
            }
        }
    }
}

#Preview {
    UserDataIntake()
        .environment(UserProfileModel())
}
