//
//  WorkoutRecommendationService.swift
//  Rep-Right
//
//  Created by Antigravity on 13/06/26.
//

import Foundation

struct WorkoutRecommendationService {
    private let weekStart: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Sunday
        return calendar
    }()
    
    init() {}
    
    // MARK: - Helper to resolve exercises
    private func resolvedExercise(
        for record: CompletedExerciseRecord,
        catalogById: [UUID: Exercise],
        catalogByName: [String: Exercise]
    ) -> Exercise? {
        catalogById[record.exerciseId] ?? catalogByName[record.exerciseName]
    }
    
    // MARK: - Recovery Analysis Methods
    
    func muscleRecoveryStatus(
        completedExercises: [CompletedExerciseRecord],
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
    
    func recoveryMap(
        completedExercises: [CompletedExerciseRecord],
        using catalog: [Exercise],
        now: Date = Date()
    ) -> [RecoveryFocusSnapshot] {
        let counts = weeklyFocusAreaCounts(completedExercises: completedExercises, using: catalog, now: now)
        let recentCounts = recentFocusAreaCounts(completedExercises: completedExercises, using: catalog, now: now)
        let lastTrained = lastTrainedDatesByFocusArea(completedExercises: completedExercises, using: catalog)
        
        return FocusArea.allCases.map { focusArea in
            let weeklyLoad = counts[focusArea, default: 0]
            let recentLoad = recentCounts[focusArea, default: 0]
            let recoveryWindow = recoveryWindowHours(forWeeklyLoad: weeklyLoad, recentLoad: recentLoad)
            let lastTrainedAt = lastTrained[focusArea]
            let elapsedHours = lastTrainedAt.map { now.timeIntervalSince($0) / 3600.0 } ?? .greatestFiniteMagnitude
            let recoveryHoursRemaining = max(0, recoveryWindow - elapsedHours)
            
            let status: FocusAreaLoadStatus
            if weeklyLoad >= 12 || recentLoad >= 5 {
                status = .overtrained
            } else if weeklyLoad >= 7 {
                status = .onTrack
            } else {
                status = .undertrained
            }
            
            return RecoveryFocusSnapshot(
                focusArea: focusArea,
                weeklyLoad: weeklyLoad,
                recentLoad: recentLoad,
                lastTrainedAt: lastTrainedAt,
                recoveryHoursRemaining: recoveryHoursRemaining,
                status: status
            )
        }
    }
    
    func overtrainedFocusAreas(
        completedExercises: [CompletedExerciseRecord],
        using catalog: [Exercise],
        now: Date = Date()
    ) -> [RecoveryFocusSnapshot] {
        recoveryMap(completedExercises: completedExercises, using: catalog, now: now)
            .filter { $0.status == .overtrained || $0.recoveryHoursRemaining > 0 }
    }
    
    func focusAreaLoadInsights(
        completedExercises: [CompletedExerciseRecord],
        using catalog: [Exercise],
        now: Date = Date()
    ) -> [FocusAreaLoadInsight] {
        recoveryMap(completedExercises: completedExercises, using: catalog, now: now).map { snapshot in
            FocusAreaLoadInsight(
                focusArea: snapshot.focusArea,
                weeklyExercises: snapshot.weeklyLoad,
                status: snapshot.status
            )
        }
    }
    
    func weeklyFocusAreaChartData(
        completedExercises: [CompletedExerciseRecord],
        using catalog: [Exercise],
        now: Date = Date()
    ) -> [(category: String, value: Double)] {
        let counts = weeklyFocusAreaCounts(completedExercises: completedExercises, using: catalog, now: now)
        return FocusArea.allCases.map { focusArea in
            (category: focusArea.rawValue, value: Double(counts[focusArea, default: 0]))
        }
    }
    
    func weeklyFocusAreaCounts(
        completedExercises: [CompletedExerciseRecord],
        using catalog: [Exercise],
        now: Date = Date()
    ) -> [FocusArea: Int] {
        let startOfWeek = weekStart.date(
            from: weekStart.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        ) ?? weekStart.startOfDay(for: now)

        let weekRecords = completedExercises.filter { $0.date >= startOfWeek }
        let catalogById = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })
        let catalogByName = Dictionary(uniqueKeysWithValues: catalog.map { ($0.name, $0) })

        var counts = Dictionary(uniqueKeysWithValues: FocusArea.allCases.map { ($0, 0) })

        for record in weekRecords {
            guard let exercise = resolvedExercise(for: record, catalogById: catalogById, catalogByName: catalogByName) else { continue }
            if let focusArea = exercise.primaryFocusArea {
                counts[focusArea, default: 0] += 1
            }
        }

        return counts
    }
    
    // MARK: - Recommendation Engine Methods
    
    func smartPresetRecommendation(
        completedExercises: [CompletedExerciseRecord],
        from presets: [Preset],
        using catalog: [Exercise]
    ) -> Preset? {
        recommendedPresets(completedExercises: completedExercises, from: presets, using: catalog, limit: 1).first?.preset
    }
    
    func recommendedPresets(
        completedExercises: [CompletedExerciseRecord],
        from presets: [Preset],
        using catalog: [Exercise],
        now: Date = Date(),
        limit: Int = 3
    ) -> [PresetRecommendation] {
        let recoveryByFocus = Dictionary(
            uniqueKeysWithValues: recoveryMap(completedExercises: completedExercises, using: catalog, now: now)
                .map { ($0.focusArea, $0) }
        )
        let activePresets = presets.filter { !$0.isRestDay && !$0.exercises.isEmpty }
        
        let scored = activePresets.compactMap { preset -> PresetRecommendation? in
            let focusAreas = presetRecommendationFocusAreas(for: preset)
            guard !focusAreas.isEmpty else { return nil }
            
            let recovering = focusAreas.filter { recoveryByFocus[$0]?.recoveryHoursRemaining ?? 0 > 0 }
            let overloaded = focusAreas.filter { recoveryByFocus[$0]?.status == .overtrained }
            
            var score = 50
            for area in focusAreas {
                guard let snapshot = recoveryByFocus[area] else { continue }
                switch snapshot.status {
                case .undertrained:
                    score += 18
                case .onTrack:
                    score += 8
                case .overtrained:
                    score -= 24
                }
                
                if snapshot.recoveryHoursRemaining > 0 {
                    score -= Int(min(snapshot.recoveryHoursRemaining, 24).rounded())
                }
                
                if snapshot.weeklyLoad == 0 {
                    score += 8
                }
            }
            
            if focusAreas.count >= 2 {
                score += 6
            }
            
            if overloaded.count == focusAreas.count {
                score -= 25
            }
            
            let headline: String
            let reason: String
            
            if overloaded.isEmpty && recovering.isEmpty {
                let targetText = formattedFocusAreas(focusAreas)
                headline = "Best time to train \(targetText.lowercased())"
                reason = "These focus areas are the freshest in your recovery map, so this preset helps balance your week without stacking fatigued muscles."
            } else if !overloaded.isEmpty {
                headline = "Use only if you want extra volume"
                reason = "\(formattedFocusAreas(overloaded)) already carry high load. This preset is still available, but recovery-first options rank higher right now."
            } else {
                headline = "Playable with some caution"
                reason = "\(formattedFocusAreas(recovering)) still need a bit more recovery, but this preset has the lightest overlap among your current options."
            }
            
            return PresetRecommendation(
                preset: preset,
                score: score,
                primaryFocusAreas: focusAreas,
                recoveringFocusAreas: recovering,
                headline: headline,
                reason: reason
            )
        }
        
        return scored
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.preset.name < rhs.preset.name
                }
                return lhs.score > rhs.score
            }
            .prefix(limit)
            .map { $0 }
    }
    
    func generatedWeeklySchedule(
        completedExercises: [CompletedExerciseRecord],
        from presets: [Preset],
        using catalog: [Exercise],
        trainingDays: Int,
        now: Date = Date()
    ) -> [ScheduledPresetRecommendation] {
        let desiredTrainingDays = min(max(trainingDays, 2), 6)
        let slots = recommendedTrainingPattern(for: desiredTrainingDays)
        let activeRecoveryPreset = presets.first(where: { $0.isRestDay || $0.name.localizedCaseInsensitiveContains("recovery") }) ?? Preset(
            isRestDay: true,
            name: "Active Recovery",
            image: "Core",
            exercises: [],
            isWarmpUp: true,
            scheduledFor: nil,
            estTime: 20,
            equipments: [],
            calories: 120
        )
        
        let candidateRecommendations = recommendedPresets(completedExercises: completedExercises, from: presets, using: catalog, now: now, limit: max(presets.count, 6))
        let recommendationLookup = Dictionary(uniqueKeysWithValues: candidateRecommendations.map { ($0.preset.id, $0) })
        let activePresets = candidateRecommendations.map(\.preset)
        
        var selected: [Weekday: Preset] = [:]
        var previousFocusAreas: Set<FocusArea> = []
        var usedPresetIDs: Set<UUID> = []
        
        for weekday in slots {
            let nextPreset = activePresets.max { lhs, rhs in
                dynamicScheduleScore(
                    for: lhs,
                    recommendation: recommendationLookup[lhs.id],
                    previousFocusAreas: previousFocusAreas,
                    hasBeenUsed: usedPresetIDs.contains(lhs.id)
                ) < dynamicScheduleScore(
                    for: rhs,
                    recommendation: recommendationLookup[rhs.id],
                    previousFocusAreas: previousFocusAreas,
                    hasBeenUsed: usedPresetIDs.contains(rhs.id)
                )
            } ?? activeRecoveryPreset
            
            selected[weekday] = withScheduledDay(nextPreset, weekday: weekday)
            previousFocusAreas = Set(presetRecommendationFocusAreas(for: nextPreset))
            usedPresetIDs.insert(nextPreset.id)
        }
        
        return Weekday.allCases.map { weekday in
            let preset = selected[weekday].map { withScheduledDay($0, weekday: weekday) } ?? withScheduledDay(activeRecoveryPreset, weekday: weekday)
            let note: String
            if slots.contains(weekday) {
                let areas = presetRecommendationFocusAreas(for: preset)
                note = areas.isEmpty
                    ? "Low-impact movement day."
                    : "Built around \(formattedFocusAreas(areas).lowercased()) based on your current recovery map."
            } else {
                note = "Scheduled as recovery so your worked muscles can bounce back before the next harder session."
            }
            
            return ScheduledPresetRecommendation(weekday: weekday, preset: preset, note: note)
        }
    }
    
    // MARK: - Private Helpers
    
    private func recoveryWindowHours(forWeeklyLoad weeklyLoad: Int, recentLoad: Int) -> Double {
        if weeklyLoad >= 12 || recentLoad >= 5 {
            return 72.0 // High
        }
        if weeklyLoad >= 7 || recentLoad >= 3 {
            return 60.0 // Elevated
        }
        return 48.0 // Base
    }
    
    private func recentFocusAreaCounts(
        completedExercises: [CompletedExerciseRecord],
        using catalog: [Exercise],
        now: Date
    ) -> [FocusArea: Int] {
        let windowStart = now.addingTimeInterval(-48.0 * 3600) // 48 hours
        let recentRecords = completedExercises.filter { $0.date >= windowStart }
        let catalogById = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })
        let catalogByName = Dictionary(uniqueKeysWithValues: catalog.map { ($0.name, $0) })
        
        var counts = Dictionary(uniqueKeysWithValues: FocusArea.allCases.map { ($0, 0) })
        for record in recentRecords {
            guard let exercise = resolvedExercise(for: record, catalogById: catalogById, catalogByName: catalogByName),
                  let focusArea = exercise.primaryFocusArea else { continue }
            counts[focusArea, default: 0] += 1
        }
        return counts
    }
    
    private func lastTrainedDatesByFocusArea(
        completedExercises: [CompletedExerciseRecord],
        using catalog: [Exercise]
    ) -> [FocusArea: Date] {
        let catalogById = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })
        let catalogByName = Dictionary(uniqueKeysWithValues: catalog.map { ($0.name, $0) })
        var result: [FocusArea: Date] = [:]
        
        for record in completedExercises {
            guard let exercise = resolvedExercise(for: record, catalogById: catalogById, catalogByName: catalogByName),
                  let focusArea = exercise.primaryFocusArea else { continue }
            
            if let existing = result[focusArea] {
                result[focusArea] = max(existing, record.endTime)
            } else {
                result[focusArea] = record.endTime
            }
        }
        
        return result
    }
    
    private func presetRecommendationFocusAreas(for preset: Preset) -> [FocusArea] {
        var ordered: [FocusArea] = []
        for exercise in preset.exercises {
            guard let area = exercise.primaryFocusArea, !ordered.contains(area) else { continue }
            ordered.append(area)
        }
        return ordered
    }
    
    private func recommendedTrainingPattern(for trainingDays: Int) -> [Weekday] {
        switch trainingDays {
        case 2:
            return [.tuesday, .friday]
        case 3:
            return [.monday, .wednesday, .friday]
        case 4:
            return [.monday, .tuesday, .thursday, .saturday]
        case 5:
            return [.monday, .tuesday, .thursday, .friday, .saturday]
        default:
            return [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        }
    }
    
    private func dynamicScheduleScore(
        for preset: Preset,
        recommendation: PresetRecommendation?,
        previousFocusAreas: Set<FocusArea>,
        hasBeenUsed: Bool
    ) -> Int {
        let focusAreas = Set(presetRecommendationFocusAreas(for: preset))
        let overlapPenalty = focusAreas.intersection(previousFocusAreas).count * 18
        let repetitionPenalty = hasBeenUsed ? 14 : 0
        let baseScore = recommendation?.score ?? 40
        return baseScore - overlapPenalty - repetitionPenalty
    }
    
    private func withScheduledDay(_ preset: Preset, weekday: Weekday) -> Preset {
        var updated = preset
        updated.scheduledFor = weekday
        return updated
    }
    
    private func formattedFocusAreas(_ focusAreas: [FocusArea]) -> String {
        switch focusAreas.count {
        case 0:
            return "recovery work"
        case 1:
            return focusAreas[0].rawValue
        case 2:
            return focusAreas[0].rawValue + " and " + focusAreas[1].rawValue
        default:
            let leading = focusAreas.dropLast().map(\.rawValue).joined(separator: ", ")
            return leading + ", and " + (focusAreas.last?.rawValue ?? "")
        }
    }
}
