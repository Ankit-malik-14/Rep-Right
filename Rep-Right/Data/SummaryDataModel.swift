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
    
    // MET-based calorie data: stored at creation time using WorkoutSummaryManager.calculateCalories
    let caloriesBurnedValue: Double?
    
    // Computed property
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    /// Returns the pre-calculated calorie value if available,
    /// otherwise falls back to a MET 3.5 estimate using the provided weight.
    func caloriesBurned(userWeightKg: Double) -> Double {
        if let stored = caloriesBurnedValue {
            return stored
        }
        // Fallback: moderate-effort MET 3.5
        let timeInHours = duration / 3600
        return 3.5 * userWeightKg * timeInHours
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

enum FocusAreaLoadStatus: String, CaseIterable, Hashable {
    case undertrained = "Under"
    case onTrack = "On Track"
    case overtrained = "Over"
}

struct FocusAreaLoadInsight: Identifiable, Hashable {
    var id: String { focusArea.rawValue }
    let focusArea: FocusArea
    let weeklyExercises: Int
    let status: FocusAreaLoadStatus

    var recommendation: String {
        switch weeklyExercises {
        case 0:
            return "Fresh this week. Safe to train."
        case 1...6:
            return "Light volume. You can add more."
        case 7...9:
            return "Close to target. One more session is fine."
        case 10...12:
            return "Ideal weekly range reached."
        default:
            return "Above weekly limit. Prioritize recovery."
        }
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
    
    
    // MARK: - MET-Based Calorie Calculation Engine
    
    /// Pure function: Calculates exact calories burned using the scientific MET formula.
    /// Formula: Calories = MET × Weight (kg) × Time (hours)
    /// - Parameters:
    ///   - exercise: The Exercise being performed (provides .metValue from the MET dictionary)
    ///   - durationInSeconds: Exact TimeInterval captured from the active workout timer
    ///   - weightInKg: User's weight from UserProfile (defaults to 70kg if nil/unavailable)
    /// - Returns: Calories burned as a Double
    func calculateCalories(for exercise: Exercise, durationInSeconds: TimeInterval, weightInKg: Double) -> Double {
        let timeInHours = durationInSeconds / 3600.0
        return exercise.metValue * weightInKg * timeInHours
    }
    
    // adds a single exercise into completedExercises array
//    func logStandaloneExercise(exerciseId: UUID, actualSet: [SetData], startTime: Date, endTime: Date, caloriesBurned: Double? = nil) {
//        let record = CompletedExerciseRecord(
//            id: UUID(),
//            exerciseId: exerciseId,
//            presetId: nil,
//            workoutSessionId: nil,
//            date: startTime,
//            startTime: startTime,
//            endTime: endTime,
//            actualSet: actualSet,
//            formAccuracy: nil,
//            formInsights: nil,
//            caloriesBurnedValue: caloriesBurned
//        )
//        completedExercises.append(record)
//    }
//    
//    func logPresetSession(presetId: UUID, exercises: [(exerciseId: UUID, actualSet: [SetData], startTime: Date, endTime: Date, caloriesBurned: Double?)]) {
//        let sessionId = UUID()
//        let sessionDate = exercises.first?.startTime ?? Date()
//        
//        // logs the overall session
//        let session = CompletedPresetRecord(id: sessionId, presetId: presetId, date: sessionDate)
//        completedSessions.append(session)
//        
//        // logs all individual exercises wrt to this session
//        let exerciseRecords = exercises.map { data in
//            CompletedExerciseRecord(
//                id: UUID(),
//                exerciseId: data.exerciseId,
//                presetId: presetId,
//                workoutSessionId: sessionId,
//                date: data.startTime,
//                startTime: data.startTime,
//                endTime: data.endTime,
//                actualSet: data.actualSet,
//                formAccuracy: nil,
//                formInsights: nil,
//                caloriesBurnedValue: data.caloriesBurned
//            )
//        }
//        completedExercises.append(contentsOf: exerciseRecords)
//    }
    
    // MARK: - Unified Logging Engine
    // Replaces logStandaloneExercise and logPresetSession

    func logWorkout(
        presetId: UUID?, // Pass nil for standalone exercises
        exercises: [(exerciseId: UUID, actualSet: [SetData], startTime: Date, endTime: Date, caloriesBurned: Double?)]
    ) {
        // 1. Handle the session wrapper if a presetId is provided
        let sessionId = presetId != nil ? UUID() : nil
        let sessionDate = exercises.first?.startTime ?? Date()
        
        if let validPresetId = presetId, let validSessionId = sessionId {
            let session = CompletedPresetRecord(id: validSessionId, presetId: validPresetId, date: sessionDate)
            completedSessions.append(session)
        }
        
        // 2. Log all individual exercises
        let exerciseRecords = exercises.map { data in
            CompletedExerciseRecord(
                id: UUID(),
                exerciseId: data.exerciseId,
                presetId: presetId,
                workoutSessionId: sessionId, // Automatically routes to presetSessions or standaloneExercises based on presence
                date: data.startTime,
                startTime: data.startTime,
                endTime: data.endTime,
                actualSet: data.actualSet,
                formAccuracy: nil,
                formInsights: nil,
                caloriesBurnedValue: data.caloriesBurned
            )
        }
        completedExercises.append(contentsOf: exerciseRecords)
    }
    
    // MARK: - Recovery & Smart Recommendations
    
    // Returns muscle groups that are still within their 48hr recovery window
    // before the user starts a given preset
    func muscleRecoveryStatus(
        for preset: Preset,
        using catalog: [Exercise],
        windowHours: Double = 48
    ) -> [(muscle: String, hoursRemaining: Double)] {
        let now = Date()
        let windowStart = now.addingTimeInterval(-windowHours * 3600)

        // All exercises done within the window
        let recentRecords = completedExercises.filter { $0.date >= windowStart }

        // Flatten to muscle groups touched recently, with their last training time
        var lastTrained: [String: Date] = [:]
        for record in recentRecords {
            guard let exercise = catalog.first(where: { $0.id == record.exerciseId }) else { continue }
            for muscle in exercise.targetAreas {
                if let existing = lastTrained[muscle] {
                    lastTrained[muscle] = max(existing, record.endTime)
                } else {
                    lastTrained[muscle] = record.endTime
                }
            }
        }

        // Cross-reference against the target preset's muscles
        let presetMuscles = Set(preset.exercises.flatMap { $0.targetAreas })

        return presetMuscles.compactMap { muscle in
            guard let trainedAt = lastTrained[muscle] else { return nil }
            let hoursElapsed = now.timeIntervalSince(trainedAt) / 3600
            let hoursRemaining = windowHours - hoursElapsed
            guard hoursRemaining > 0 else { return nil }
            return (muscle: muscle, hoursRemaining: hoursRemaining)
        }.sorted { $0.hoursRemaining > $1.hoursRemaining }
    }

    // Suggests the best preset to do today, avoiding overworked muscles
    func smartPresetRecommendation(
        from presets: [Preset],
        using catalog: [Exercise]
    ) -> Preset? {
        presets
            .filter { !$0.isRestDay && !$0.exercises.isEmpty }
            .min { a, b in
                muscleRecoveryStatus(for: a, using: catalog).count <
                muscleRecoveryStatus(for: b, using: catalog).count
            }
    }

    func focusAreaLoadInsights(using catalog: [Exercise], now: Date = Date()) -> [FocusAreaLoadInsight] {
        let counts = weeklyFocusAreaCounts(using: catalog, now: now)

        return FocusArea.allCases.map { focusArea in
            let weeklyExercises = counts[focusArea, default: 0]
            let status: FocusAreaLoadStatus

            if weeklyExercises > 12 {
                status = .overtrained
            } else if weeklyExercises >= 10 {
                status = .onTrack
            } else {
                status = .undertrained
            }

            return FocusAreaLoadInsight(
                focusArea: focusArea,
                weeklyExercises: weeklyExercises,
                status: status
            )
        }
    }

    func weeklyFocusAreaChartData(using catalog: [Exercise], now: Date = Date()) -> [(category: String, value: Double)] {
        let counts = weeklyFocusAreaCounts(using: catalog, now: now)
        return FocusArea.allCases.map { focusArea in
            (category: focusArea.rawValue, value: Double(counts[focusArea, default: 0]))
        }
    }

    private func weeklyFocusAreaCounts(using catalog: [Exercise], now: Date = Date()) -> [FocusArea: Int] {
        let startOfWeek = weekStart.date(
            from: weekStart.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        ) ?? weekStart.startOfDay(for: now)

        let weekRecords = completedExercises.filter { $0.date >= startOfWeek }
        let catalogById = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })

        var counts = Dictionary(uniqueKeysWithValues: FocusArea.allCases.map { ($0, 0) })

        for record in weekRecords {
            guard let exercise = catalogById[record.exerciseId] else { continue }
            if let focusArea = exercise.primaryFocusArea {
                counts[focusArea, default: 0] += 1
            }
        }

        return counts
    }

    // MARK: - Computed Metrics for UI 
    var totalExercisesCurrentWeek: Int {
        weeklySummaries.first?.dailySummaries.reduce(0) { $0 + $1.exercises.count } ?? 0
    }
    
    var totalTimeCurrentWeekInHours: Double {
        let seconds = weeklySummaries.first?.totalDuration ?? 0
        return seconds / 3600.0
    }
    
    // UPDATED: Added target goals to support replacing the deprecated SummaryData
    var targetActiveMinutes: Int = 250
    
    var activeMinutesCurrentWeek: Int {
        let minutes = (weeklySummaries.first?.totalDuration ?? 0) / 60.0
        return Int(minutes)
    }
    
    var calorieProgress: Double {
        let weeklyTarget = dailyCalorieGoal * 7.0
        let burned = weeklyCalorieChartData.reduce(0.0) { $0 + Double($1.calories) }
        return weeklyTarget > 0 ? min(burned / weeklyTarget, 1.0) : 0.0
    }
    
    var currentStreak: Int {
        // Simplified streak: counts how many days in a row have exercises, starting from today backward.
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())
        
        while true {
            if dailySummaries.contains(where: { calendar.isDate($0.date, inSameDayAs: checkDate) }) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                if streak == 0 && calendar.isDateInToday(checkDate) {
                    // Try yesterday if today has nothing yet
                    checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                    if dailySummaries.contains(where: { calendar.isDate($0.date, inSameDayAs: checkDate) }) {
                        streak += 1
                        checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                        continue
                    }
                }
                break
            }
        }
        return streak
    }
    
    var weeklyCalorieChartData: [(day: String, calories: Int)] {
        // Build 7 days array dynamically
        let calendar = Calendar.current
        var targetDays: [Date] = []
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        
        for i in 0..<7 {
            if let d = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                targetDays.append(d)
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        return targetDays.map { date in
            let match = dailySummaries.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
            let cals = match?.totalCalories(userWeightKg: currentUserWeight) ?? 0
            return (day: formatter.string(from: date), calories: Int(cals))
        }
    }
    
    // MARK: - Form Accuracy Metrics
    
    /// Most recent non-nil form insight string from completed exercises
    var latestFormInsight: String? {
        let recordsWithInsights = completedExercises
            .filter { $0.formInsights != nil && !($0.formInsights!.isEmpty) }
            .sorted { $0.date > $1.date }
        return recordsWithInsights.first?.formInsights?.first
    }
    
    /// Average form accuracy across all exercises that have a recorded accuracy value (0.0–1.0 scale)
    var averageFormAccuracy: Double {
        let accuracies = completedExercises.compactMap { $0.formAccuracy }
        guard !accuracies.isEmpty else { return 0.0 }
        return accuracies.reduce(0, +) / Double(accuracies.count) / 100.0
    }
    
    // MARK: - Daily Calorie Metrics
    
    /// User-configurable daily calorie goal
    var dailyCalorieGoal: Double = 500.0
    
    /// Total calories burned today, computed from all exercises logged today
    var todayCaloriesBurned: Double {
        let calendar = Calendar.current
        let todaysExercises = completedExercises.filter { calendar.isDateInToday($0.date) }
        return todaysExercises.reduce(0) { $0 + $1.caloriesBurned(userWeightKg: currentUserWeight) }
    }
    
    // MARK: - Target Area Breakdown (for ExerciseRingView)
    
    /// Groups this week's completed exercises by their target area, counting occurrences.
    /// Requires the full exercise catalog to resolve exerciseId → targetAreas.
    func exercisesByTargetArea(using catalog: [Exercise]) -> [(category: String, value: Double)] {
        weeklyFocusAreaChartData(using: catalog)
            .filter { $0.value > 0 }
    }
    
    // MARK: - Weekly Activity by Day (for TotalTimeExerciseView)
    
    /// Maps each day of the current week to its primary target area and total minutes.
    /// Requires the full exercise catalog to resolve exerciseId → targetAreas.
    func weeklyActivityByDay(using catalog: [Exercise]) -> [(day: String, category: String, minutes: Double)] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        var result: [(day: String, category: String, minutes: Double)] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) else { continue }
            let dayStr = formatter.string(from: date)
            
            let dayExercises = completedExercises.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let totalMinutes = dayExercises.reduce(0.0) { $0 + $1.duration } / 60.0
            
            // Find the primary target area for this day
            var areaCounts: [String: Int] = [:]
            for record in dayExercises {
                if let exercise = catalog.first(where: { $0.id == record.exerciseId }) {
                    for area in exercise.targetAreas {
                        areaCounts[area, default: 0] += 1
                    }
                }
            }
            let primaryArea = areaCounts.max(by: { $0.value < $1.value })?.key ?? "Rest"
            
            if totalMinutes > 0 {
                result.append((day: dayStr, category: primaryArea, minutes: totalMinutes))
            }
        }
        
        return result
    }
}
