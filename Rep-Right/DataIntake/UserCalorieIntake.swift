//
//  UserCalorieIntake.swift
//  Rep_Right
//
//  Created by Mayurakshi Das on 01/04/26.
//

import SwiftUI



/* DEPRECATED: CalorieGoalViewModel is deprecated. Replaced by direct binding to WorkoutSummaryManager.dailyCalorieGoal.
// MARK: - DATA STORE

@Observable
class CalorieGoalViewModel {
    var dailyGoal: Int = 500
    private let step = 50
    
    // computed property to bridge integer goal to text strings
    var goalText: String {
            get { String(dailyGoal) }
            set {
                // Only update if the user types a valid number
                if let newValueInt = Int(newValue) {
                    dailyGoal = newValueInt
                } else if newValue.isEmpty {
                    dailyGoal = 0
                }
            }
        }
    
    func decreaseGoal() {
        if dailyGoal >= step {
            dailyGoal -= step
        }else{
            dailyGoal = 0
        }
    }
    
    func increaseGoal() {
        dailyGoal += step
    }
}
*/

//MARK: - VIEW
// UPDATED: Now uses WorkoutSummaryManager as the single source of truth for the calorie goal.
struct UserCalorieIntake: View, Hashable{
    static func == (lhs: UserCalorieIntake, rhs: UserCalorieIntake) -> Bool {
            // Since there are no initialized properties (only State/Environment),
            // all instances of this view are structurally identical.
            return true
        }
            
    func hash(into hasher: inout Hasher) {
        // Hash a constant or the type itself so the hash value is consistent
        hasher.combine(String(describing: Self.self))
    }
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(\.dismiss) private var dismiss
    
    // computed property to bridge double goal to text strings for the TextField
    private var goalText: Binding<String> {
        Binding(
            get: { String(Int(summaryManager.dailyCalorieGoal)) },
            set: { newValue in
                if let newValueInt = Int(newValue) {
                    summaryManager.dailyCalorieGoal = Double(newValueInt)
                } else if newValue.isEmpty {
                    summaryManager.dailyCalorieGoal = 0
                }
            }
        )
    }

        var body: some View {
            
                VStack(spacing: 0) {
                    // 1. TOP HEADER SECTION
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Daily Move Goals")
                            .font(.largeTitle.bold())
                        
                        Text("Set a goal based on how active you are, or how active you'd like to be, each day")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // 2. INTERACTIVE CALCULATOR SECTION
                    VStack(spacing: 20) {
                        HStack(spacing: 25) {
                            // MINUS
                            Button {
                                if summaryManager.dailyCalorieGoal >= 50 {
                                    summaryManager.dailyCalorieGoal -= 50
                                } else {
                                    summaryManager.dailyCalorieGoal = 0
                                }
                            } label: {
                                ZStack{
                                    Circle()
                                        .frame(width: 70, height: 70)
                                        .foregroundStyle(.orange)
                                    Text("-")
                                        .font(.largeTitle.bold())
                                }
                            }.tint(.black)
                            // VALUE
                            TextField("", text: goalText)
                                .font(.system(size: 80).bold())
                                .multilineTextAlignment(.center)
                            // PLUS
                            Button {
                                summaryManager.dailyCalorieGoal += 50
                            } label: {
                                ZStack{
                                    Circle()
                                        .frame(width: 70, height: 70)
                                        .foregroundStyle(.orange)
                                    Text("+")
                                        .font(.largeTitle.bold())
                                }
                            }.tint(.black)
                        }.padding()
                        
                        Text("Calories/Day")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Button {
                        // Logic to save the data
                        print("Saved goal: \(summaryManager.dailyCalorieGoal)")
                        dismiss()
                    } label: {
                        ContinueButton()
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Skip")
                                .foregroundStyle(.orange)
                        }
                        
                        .buttonStyle(.bordered)
                        
                    }
                }

                .frame(maxWidth: .infinity, maxHeight: .infinity)
                //.background(Color(.systemBackground))
            
    }
}

#Preview {
    NavigationStack{
        UserCalorieIntake()
            .environment(WorkoutSummaryManager())
    }
}
