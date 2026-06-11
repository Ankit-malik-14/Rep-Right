//
//  RecommendationEngine.swift
//  Rep_Right
//
//  Created by Jugad on 06/04/26.
//

import Foundation

struct RecoveryFocusSnapshot: Identifiable, Hashable {
    var id: FocusArea { focusArea }
    let focusArea: FocusArea
    let weeklyLoad: Int
    let recentLoad: Int
    let lastTrainedAt: Date?
    let recoveryHoursRemaining: Double
    let status: FocusAreaLoadStatus
    
    var loadLimit: Int { 12 }
    
    var guidance: String {
        if status == .overtrained {
            if recoveryHoursRemaining > 0 {
                return "Back off for \(Int(recoveryHoursRemaining.rounded(.up))) more hrs and rotate to fresher muscles."
            }
            return "Weekly volume is too high. Shift away from this area for the next session."
        }
        
        if status == .onTrack {
            if recoveryHoursRemaining > 0 {
                return "Progress is solid, but give it a little more recovery before loading it again."
            }
            return "This area is in a healthy range. Keep it in rotation, not back-to-back."
        }
        
        if weeklyLoad == 0 {
            return "Completely fresh this week. Great candidate for your next preset."
        }
        
        return "Lightly trained so far. You can safely add more focused work here."
    }
}

struct PresetRecommendation: Identifiable, Hashable {
    let preset: Preset
    let score: Int
    let primaryFocusAreas: [FocusArea]
    let recoveringFocusAreas: [FocusArea]
    let headline: String
    let reason: String
    
    var id: UUID { preset.id }
}

struct ScheduledPresetRecommendation: Identifiable, Hashable {
    let weekday: Weekday
    let preset: Preset
    let note: String
    
    var id: Int { weekday.rawValue }
}

private enum RecommendationTuning {
    static let weeklyWindowDays = 7
    static let baseRecoveryHours = 48.0
    static let elevatedRecoveryHours = 60.0
    static let highRecoveryHours = 72.0
    static let recentWindowHours = 48.0
}

extension WorkoutSummaryManager {
    func recoveryMap(using catalog: [Exercise], now: Date = Date()) -> [RecoveryFocusSnapshot] {
        let counts = weeklyFocusAreaCounts(using: catalog, now: now)
        let recentCounts = recentFocusAreaCounts(using: catalog, now: now)
        let lastTrained = lastTrainedDatesByFocusArea(using: catalog)
        
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
    
    func recommendedPresets(
        from presets: [Preset],
        using catalog: [Exercise],
        now: Date = Date(),
        limit: Int = 3
    ) -> [PresetRecommendation] {
        let recoveryByFocus = Dictionary(uniqueKeysWithValues: recoveryMap(using: catalog, now: now).map { ($0.focusArea, $0) })
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
        
        let candidateRecommendations = recommendedPresets(from: presets, using: catalog, now: now, limit: max(presets.count, 6))
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
    
    func overtrainedFocusAreas(using catalog: [Exercise], now: Date = Date()) -> [RecoveryFocusSnapshot] {
        recoveryMap(using: catalog, now: now).filter { $0.status == .overtrained || $0.recoveryHoursRemaining > 0 }
    }
    
    private func recoveryWindowHours(forWeeklyLoad weeklyLoad: Int, recentLoad: Int) -> Double {
        if weeklyLoad >= 12 || recentLoad >= 5 {
            return RecommendationTuning.highRecoveryHours
        }
        if weeklyLoad >= 7 || recentLoad >= 3 {
            return RecommendationTuning.elevatedRecoveryHours
        }
        return RecommendationTuning.baseRecoveryHours
    }
    
    private func recentFocusAreaCounts(using catalog: [Exercise], now: Date) -> [FocusArea: Int] {
        let windowStart = now.addingTimeInterval(-RecommendationTuning.recentWindowHours * 3600)
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
    
    private func lastTrainedDatesByFocusArea(using catalog: [Exercise]) -> [FocusArea: Date] {
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
