//
//  SummaryDashboardViewModel.swift
//  Rep-Right
//
//  Created by Antigravity on 13/06/26.
//

import Foundation
import Observation

@Observable
class SummaryDashboardViewModel {
    private(set) var summaryManager: WorkoutSummaryManager
    private(set) var userProfile: UserProfileModel
    private(set) var exercises: Exercises
    
    init(summaryManager: WorkoutSummaryManager, userProfile: UserProfileModel, exercises: Exercises) {
        self.summaryManager = summaryManager
        self.userProfile = userProfile
        self.exercises = exercises
    }
    
    // MARK: - Passthrough & Domain Properties
    
    var completedExercises: [CompletedExerciseRecord] {
        summaryManager.completedExercises
    }
    
    var dailySummaries: [DailySummary] {
        summaryManager.dailySummaries
    }
    
    var weeklySummaries: [WeeklySummary] {
        summaryManager.weeklySummaries
    }
    
    var currentUserWeight: Double {
        summaryManager.currentUserWeight
    }
    
    var dailyCalorieGoal: Double {
        summaryManager.dailyCalorieGoal
    }
    
    var targetActiveMinutes: Int {
        summaryManager.targetActiveMinutes
    }
    
    var todayCaloriesBurned: Double {
        summaryManager.todayCaloriesBurned
    }
    
    var latestFormInsight: String? {
        summaryManager.latestFormInsight
    }
    
    var averageFormAccuracy: Double {
        summaryManager.averageFormAccuracy
    }
    
    var formAccuracyRecords: [CompletedExerciseRecord] {
        summaryManager.formAccuracyRecords
    }
    
    var latestFormAccuracyRecord: CompletedExerciseRecord? {
        summaryManager.latestFormAccuracyRecord
    }
    
    // MARK: - Computed Analytics & Presentational Formatting
    
    var totalExercisesCurrentWeek: Int {
        summaryManager.totalExercisesCurrentWeek
    }
    
    var totalTimeCurrentWeekInHours: Double {
        summaryManager.totalTimeCurrentWeekInHours
    }
    
    var activeMinutesCurrentWeek: Int {
        summaryManager.activeMinutesCurrentWeek
    }
    
    var calorieProgress: Double {
        summaryManager.calorieProgress
    }
    
    var currentStreak: Int {
        summaryManager.currentStreak
    }
    
    var weeklyCalorieChartData: [(day: String, calories: Int)] {
        summaryManager.weeklyCalorieChartData
    }
    
    var totalCaloriesBurnedCurrentWeek: Int {
        weeklyCalorieChartData.reduce(0) { $0 + $1.calories }
    }
    
    var averageCaloriesBurnedCurrentWeek: Double {
        let count = weeklyCalorieChartData.count
        guard count > 0 else { return 0 }
        return Double(totalCaloriesBurnedCurrentWeek) / Double(count)
    }
    
    var hitTargetDaysCount: Int {
        weeklyCalorieChartData.filter { Double($0.calories) >= dailyCalorieGoal }.count
    }
    
    func exercisesByTargetArea() -> [(category: String, value: Double)] {
        summaryManager.exercisesByTargetArea(using: exercises.exerciseList)
    }
    
    func weeklyActivityByDay() -> [(day: String, category: String, minutes: Double)] {
        summaryManager.weeklyActivityByDay(using: exercises.exerciseList)
    }
    
    // MARK: - Calendar Loader Logic (Moved from View to ViewModel)
    
    func loadWeek(offset: Int) -> (days: [WorkoutDay], monthYearHeader: String) {
        let calendar = Calendar.current
        let today = Date()
        
        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: offset, to: today),
              let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: targetDate)) else {
            return ([], "")
        }
        
        let headerTitle = targetDate.formatted(.dateTime.month(.wide).year())
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        var days: [WorkoutDay] = []
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: weekStart)!
            let name = formatter.string(from: date).uppercased()
            let number = "\(calendar.component(.day, from: date))"
            
            let status: String
            if calendar.isDateInToday(date) {
                status = "current"
            } else if date > today {
                status = "future"
            } else {
                let hasWorkout = dailySummaries.contains(where: { calendar.isDate($0.date, inSameDayAs: date) })
                status = hasWorkout ? "streak" : "missed"
            }
            
            days.append(WorkoutDay(name: name, number: number, status: status))
        }
        
        return (days, headerTitle)
    }
}
