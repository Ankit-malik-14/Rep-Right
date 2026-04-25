//
//  WorkoutSessionManager.swift
//  Rep-Right
//

import Foundation
import Observation
import SwiftUI

// MARK: - Interactive Set Entry

struct ExerciseSetEntry: Identifiable {
    let id = UUID()
    var setNumber: Int
    var targetReps: Int
    var reps: String
    var weight: String
    var isCompleted: Bool = false
}

// MARK: - Workout Phase State Machine

enum WorkoutPhase: Equatable {
    case preparing
    case activeExercise(Exercise)
    case resting(duration: Int)
    case finished
    
    static func == (lhs: WorkoutPhase, rhs: WorkoutPhase) -> Bool {
        switch (lhs, rhs) {
        case (.preparing, .preparing): return true
        case (.activeExercise(let a), .activeExercise(let b)): return a.id == b.id
        case (.resting(let a), .resting(let b)): return a == b
        case (.finished, .finished): return true
        default: return false
        }
    }
}

// MARK: - Navigation Router

@Observable
class WorkoutRouter {
    var path = NavigationPath()
    
    func popToRoot() {
        path = NavigationPath()
    }
}

// MARK: - Workout Session Manager

@Observable
class WorkoutSessionManager {
    let preset: Preset
    private(set) var exerciseQueue: [Exercise]
    private(set) var currentIndex: Int = 0
    
    var phase: WorkoutPhase = .preparing
    
    // Workout timer — Date-based for TimelineView (no Timer needed)
    var accumulatedTime: TimeInterval = 0
    var timerStartDate: Date? = nil
    var isTimerRunning: Bool { timerStartDate != nil }
    
    /// Computed elapsed time: banked time + current running segment.
    /// Recalculated on every TimelineView tick.
    var elapsedTime: TimeInterval {
        accumulatedTime + (timerStartDate.map { Date().timeIntervalSince($0) } ?? 0)
    }
    
    // Rest timer (kept as Timer — it drives state transitions, not just display)
    var restTimeRemaining: Int = 60
    private var restTimer: Timer?
    
    // Per-exercise set tracking (exactly 3 sets)
    var currentSets: [ExerciseSetEntry] = []
    
    // MARK: - Set History Archive
    /// Snapshots of each exercise's sets, keyed by exercise index.
    /// Populated when transitioning away from an active exercise.
    var completedSetsArchive: [Int: [ExerciseSetEntry]] = [:]
    
    private let defaultRestDuration = 60
    
    init(preset: Preset) {
        self.preset = preset
        self.exerciseQueue = preset.exercises
    }
    
    // MARK: - Computed Properties
    
    var currentExercise: Exercise? {
        guard exerciseQueue.indices.contains(currentIndex) else { return nil }
        return exerciseQueue[currentIndex]
    }
    
    var isOnLastExercise: Bool {
        currentIndex >= exerciseQueue.count - 1
    }
    
    var progress: Double {
        guard !exerciseQueue.isEmpty else { return 0 }
        if case .finished = phase { return 1.0 }
        return Double(currentIndex) / Double(exerciseQueue.count)
    }
    
    /// Number of exercises that had at least one completed set.
    var completedExerciseCount: Int {
        completedSetsArchive.values.filter { sets in
            sets.contains(where: \.isCompleted)
        }.count
    }
    
    var elapsedTimeFormatted: String {
        let m = Int(elapsedTime) / 60
        let s = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    var currentSetLabel: String {
        let completed = currentSets.filter(\.isCompleted).count
        let current = min(completed + 1, currentSets.count)
        return "Set \(current) of \(currentSets.count)"
    }
    
    func estimatedCalories(userWeightKg: Double) -> Int {
        let met = currentExercise?.metValue ?? 5.0
        return Int(met * userWeightKg * (elapsedTime / 3600.0))
    }
    
    // MARK: - Lifecycle
    
    func startWorkout() {
        guard !exerciseQueue.isEmpty else {
            phase = .finished
            return
        }
        currentIndex = 0
        loadSetsForCurrentExercise()
        phase = .activeExercise(exerciseQueue[0])
        startWorkoutTimer()
    }
    
    // MARK: - Set Management
    
    private func loadSetsForCurrentExercise() {
        guard let exercise = currentExercise else { return }
        
        var entries: [ExerciseSetEntry] = []
        var num = 1
        
        for group in exercise.setData {
            for _ in 0..<group.sets {
                entries.append(ExerciseSetEntry(
                    setNumber: num,
                    targetReps: group.reps,
                    reps: "\(group.reps)",
                    weight: "0"
                ))
                num += 1
            }
        }
        
        // Default to 3 sets of 8 if empty
        if entries.isEmpty {
            entries = (1...3).map {
                ExerciseSetEntry(setNumber: $0, targetReps: 8, reps: "8", weight: "0")
            }
        }
        
        // Normalize to exactly 3 sets
        if entries.count > 3 {
            entries = Array(entries.prefix(3))
            for i in entries.indices { entries[i].setNumber = i + 1 }
        } else {
            let lastReps = entries.last?.targetReps ?? 8
            while entries.count < 3 {
                entries.append(ExerciseSetEntry(
                    setNumber: entries.count + 1,
                    targetReps: lastReps,
                    reps: "\(lastReps)",
                    weight: entries.last?.weight ?? "0"
                ))
            }
        }
        
        currentSets = entries
    }
    
    /// Archives the current exercise's sets into the history dictionary.
    func archiveCurrentSets() {
        completedSetsArchive[currentIndex] = currentSets
    }
    
    func toggleSetComplete(id: UUID) {
        guard let i = currentSets.firstIndex(where: { $0.id == id }) else { return }
        currentSets[i].isCompleted.toggle()
        
        // When all 3 sets are checked → auto-transition to rest
        if currentSets.allSatisfy(\.isCompleted) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.transitionToRest()
            }
        }
    }
    
    // MARK: - State Transitions
    
    func skipExercise() {
        archiveCurrentSets()
        isOnLastExercise ? finishWorkout() : transitionToRest()
    }
    
    private func transitionToRest() {
        archiveCurrentSets()
        stopRestTimer()
        restTimeRemaining = defaultRestDuration
        phase = .resting(duration: defaultRestDuration)
        startRestTimer()
    }
    
    func skipRest() {
        stopRestTimer()
        moveToNextExercise()
    }
    
    private func moveToNextExercise() {
        if isOnLastExercise {
            finishWorkout()
        } else {
            currentIndex += 1
            loadSetsForCurrentExercise()
            phase = .activeExercise(exerciseQueue[currentIndex])
        }
    }
    
    func finishWorkout() {
        archiveCurrentSets()
        stopWorkoutTimer()
        stopRestTimer()
        phase = .finished
    }
    
    // MARK: - Workout Timer (Date-based, driven by TimelineView)
    
    func startWorkoutTimer() {
        timerStartDate = Date()
    }
    
    func pauseWorkoutTimer() {
        accumulatedTime = elapsedTime
        timerStartDate = nil
    }
    
    func toggleTimer() {
        isTimerRunning ? pauseWorkoutTimer() : startWorkoutTimer()
    }
    
    private func stopWorkoutTimer() {
        pauseWorkoutTimer()
    }
    
    // MARK: - Rest Timer
    
    private func startRestTimer() {
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.restTimeRemaining > 0 {
                self.restTimeRemaining -= 1
            } else {
                self.stopRestTimer()
                self.moveToNextExercise()
            }
        }
    }
    
    private func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
    }
    
    deinit {
        restTimer?.invalidate()
    }
}
