//
//  SummaryDataModel.swift
//  Rep_Right
//
//  Created by GU on 01/04/26.
//

import Foundation
import Observation

struct CompletedExerciseRecord: Identifiable, Hashable {
    let id: UUID
    let exerciseId: UUID
    let presetId: UUID?
    let workoutSessionId: UUID?
    
    let date: Date
    let startTime: Date
    let endTime: Date
    let actualSet: [SetData] // because user can change sets and reps while working out
    
    // form tracking attributes
    let formAccuracy: Double?
    let formInsights: [String]?
    
    // Computed property
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    // calculation based on user's current weight
    func caloriesBurned(userWeightKg: Double) -> Double {
        let timeInHours = duration / 3600
        let metValue = 5.0 // assumed MET value
        return metValue * userWeightKg * timeInHours
    }
}

struct CompletedPresetRecord: Identifiable, Hashable {
    let id: UUID
    let presetId: UUID
    let date: Date
}


struct DailySummary: Identifiable {
    let id = UUID()
    let date: Date
    let exercises: [CompletedExerciseRecord]
    
    var totalDuration: TimeInterval {
        exercises.reduce(0) { $0 + $1.duration }
    }
    
    var standaloneExercises: [CompletedExerciseRecord] {
        exercises.filter { $0.workoutSessionId == nil }
    }
    
    // groups exercises by the preset-session they belonged to.
    var presetSessions: [UUID: [CompletedExerciseRecord]] {
        let presetExercises = exercises.filter { $0.workoutSessionId != nil }
        return Dictionary(grouping: presetExercises) { $0.workoutSessionId! }// Dictionary {SessionID:array of exercises}
    }
    
    func totalCalories(userWeightKg: Double) -> Double {
        exercises.reduce(0) { $0 + $1.caloriesBurned(userWeightKg: userWeightKg) }
    }
}

struct WeeklySummary: Identifiable {
    let id = UUID()
    let weekStartDate: Date
    let dailySummaries: [DailySummary]
    
    var totalDuration: TimeInterval {
        dailySummaries.reduce(0) { $0 + $1.totalDuration }
    }
    
    func totalCalories(userWeightKg: Double) -> Double {
        dailySummaries.reduce(0) { $0 + $1.totalCalories(userWeightKg: userWeightKg) }
    }
}

@Observable
class WorkoutSummaryManager {
    var completedExercises: [CompletedExerciseRecord] = []
    var completedSessions: [CompletedPresetRecord] = []
    
    var currentUserWeight: Double = 71.0
    
    private var weekStart: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // assuming week starts from Sunday (Sunday-Sat is a week)
        return calendar
    }
    
    var dailySummaries: [DailySummary] {
        // Daily grouping
        let grouped = Dictionary(grouping: completedExercises) { exercise in
            weekStart.startOfDay(for: exercise.date)
        }
        
        return grouped.map { (date, exercises) in
            DailySummary(date: date, exercises: exercises)
        }.sorted { $0.date > $1.date } // Newest days first
    }
    
    // Weekly grouping
    var weeklySummaries: [WeeklySummary] {
        // Group the DailySummaries by the start of the week
        let grouped = Dictionary(grouping: dailySummaries) { dailySummary in
            // Find the start of the week for this specific day
            let components = weekStart.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dailySummary.date)
            return weekStart.date(from: components) ?? dailySummary.date
        }
        
        return grouped.map { (weekStart, dailySummariesForWeek) in
            let sortedDays = dailySummariesForWeek.sorted { $0.date > $1.date }
            return WeeklySummary(weekStartDate: weekStart, dailySummaries: sortedDays)
        }.sorted { $0.weekStartDate > $1.weekStartDate }
    }
    
    
    // adds a single exercise into completedExercises array
    func logStandaloneExercise(exerciseId: UUID, actualSet: [SetData], startTime: Date, endTime: Date) {
        let record = CompletedExerciseRecord(
            id: UUID(),
            exerciseId: exerciseId,
            presetId: nil,
            workoutSessionId: nil,
            date: startTime,
            startTime: startTime,
            endTime: endTime,
            actualSet: actualSet,
            formAccuracy: nil,
            formInsights: nil
        )
        completedExercises.append(record)
    }
    
    func logPresetSession(presetId: UUID, exercises: [(exerciseId: UUID, actualSet: [SetData], startTime: Date, endTime: Date)]) {
        let sessionId = UUID()
        let sessionDate = exercises.first?.startTime ?? Date()
        
        // logs the overall session
        let session = CompletedPresetRecord(id: sessionId, presetId: presetId, date: sessionDate)
        completedSessions.append(session)
        
        // logs all individual exercises wrt to this session
        let exerciseRecords = exercises.map { data in
            CompletedExerciseRecord(
                id: UUID(),
                exerciseId: data.exerciseId,
                presetId: presetId,
                workoutSessionId: sessionId,
                date: data.startTime,
                startTime: data.startTime,
                endTime: data.endTime,
                actualSet: data.actualSet,
                formAccuracy: nil,
                formInsights: nil
            )
        }
        completedExercises.append(contentsOf: exerciseRecords)
    }
}
