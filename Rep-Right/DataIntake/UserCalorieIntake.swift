//
//  UserCalorieIntake.swift
//  Rep_Right
//
//  Created by Mayurakshi Das on 01/04/26.
//

import SwiftUI
import Observation

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

//MARK: - VIEW
struct UserCalorieIntake: View {
    @State private var viewModel = CalorieGoalViewModel()

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
                                viewModel.decreaseGoal()
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
                            TextField("", text: $viewModel.goalText)
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)
                            
                            // PLUS
                            Button {
                                viewModel.increaseGoal()
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
                    
                    // 3. BOTTOM ACTION BUTTON
                    Button {
                        // Logic to save the data
                        print("Saved goal: \(viewModel.dailyGoal)")
                    } label: {
                        ContinueButton()
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            //
                        } label: {
                            Text("Skip")
                                .foregroundStyle(.orange)
                        }
                        
                        .buttonStyle(.bordered)
                        
                    }
                }

                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            
    }
}

#Preview {
    NavigationStack{
        UserCalorieIntake()
    }
}
