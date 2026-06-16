//
//  UserCalorieIntake.swift
//  Rep_Right
//
//  Created by Mayurakshi Das on 01/04/26.
//

import SwiftUI



// MARK: - DATA STORE

@Observable
class CalorieGoalViewModel {
    private let summaryManager: WorkoutSummaryManager
    var calorieGoal: Double = 500.0
    
    init(summaryManager: WorkoutSummaryManager) {
        self.summaryManager = summaryManager
        self.calorieGoal = summaryManager.dailyCalorieGoal
    }
    
    // computed property to bridge double goal to text strings for the TextField
    var goalText: String {
        get { String(Int(calorieGoal)) }
        set {
            if let newValueInt = Int(newValue) {
                calorieGoal = Double(newValueInt)
            } else if newValue.isEmpty {
                calorieGoal = 0
            }
        }
    }
    
    func decreaseGoal() {
        if calorieGoal >= 50 {
            calorieGoal -= 50
        } else {
            calorieGoal = 0
        }
    }
    
    func increaseGoal() {
        calorieGoal += 50
    }
    
    func saveGoal() {
        summaryManager.dailyCalorieGoal = calorieGoal
    }
}

//MARK: - VIEW
struct UserCalorieIntake: View {
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: CalorieGoalViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                UserCalorieIntakeContent()
                    .environment(viewModel)
            } else {
                Color.clear
                    .onAppear {
                        viewModel = CalorieGoalViewModel(summaryManager: summaryManager)
                    }
            }
        }
    }
}

struct UserCalorieIntakeContent: View {
    @Environment(CalorieGoalViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var viewModel = viewModel
        return VStack(spacing: 0) {
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
                        .font(.system(size: 70).bold())
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
            
            Button {
                viewModel.saveGoal()
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
                //.buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack{
        UserCalorieIntake()
            .environment(WorkoutSummaryManager())
    }
}
