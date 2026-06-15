//
//  CustomPresetsViewModel.swift
//  Rep-Right
//
//  Created by Antigravity on 13/06/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
class CustomPresetsViewModel {
    private(set) var customPresetsData: CustomPresetsDummyData
    private(set) var exercises: Exercises
    
    // List / Selection State
    var selectedPresetIDs = Set<UUID>()
    var isSelectionMode = false
    var showAddSheet = false
    
    // Addition Draft State
    var presetName: String = ""
    var selectedFocusArea: FocusArea? = nil
    var selectedExercises = Set<Exercise>()
    
    init(customPresetsData: CustomPresetsDummyData, exercises: Exercises) {
        self.customPresetsData = customPresetsData
        self.exercises = exercises
    }
    
    // MARK: - Computed Properties
    
    var customPresets: [Preset] {
        customPresetsData.customPresets
    }
    
    var filteredExercises: [Exercise] {
        guard let area = selectedFocusArea else { return [] }
        return exercises.exerciseList.filter { exercise in
            exercise.targetAreas.contains { rawArea in
                FocusArea.from(targetArea: rawArea) == area
            }
        }
    }
    
    var canContinue: Bool {
        !presetName.trimmingCharacters(in: .whitespaces).isEmpty && !selectedExercises.isEmpty
    }
    
    // MARK: - List Actions
    
    func toggleSelection(for preset: Preset) {
        if selectedPresetIDs.contains(preset.id) {
            selectedPresetIDs.remove(preset.id)
        } else {
            selectedPresetIDs.insert(preset.id)
        }
    }
    
    func deleteSelectedPresets() {
        customPresetsData.customPresets.removeAll { selectedPresetIDs.contains($0.id) }
        selectedPresetIDs.removeAll()
        isSelectionMode = false
    }
    
    // MARK: - Addition Actions
    
    func selectFocusArea(_ area: FocusArea) {
        if selectedFocusArea == area {
            selectedFocusArea = nil
            selectedExercises = []
        } else {
            selectedFocusArea = area
            selectedExercises = []
        }
    }
    
    func toggleExercise(_ exercise: Exercise) {
        if selectedExercises.contains(exercise) {
            selectedExercises.remove(exercise)
        } else {
            selectedExercises.insert(exercise)
        }
    }
    
    func resetAdditionDraft() {
        presetName = ""
        selectedFocusArea = nil
        selectedExercises = []
    }
    
    func savePreset() {
        let exercisesArray = Array(selectedExercises)
        let equipments = Array(Set(exercisesArray.flatMap { $0.equipments })).sorted()
        let estTime = max(15, exercisesArray.count * 5)
        
        let newPreset = Preset(
            name: presetName.trimmingCharacters(in: .whitespaces),
            exercises: exercisesArray,
            isWarmpUp: false,
            scheduledFor: nil,
            estTime: estTime,
            equipments: equipments,
            calories: exercisesArray.reduce(0) { $0 + Int($1.metValue * Double(estTime) / Double(exercisesArray.count)) }
        )
        
        customPresetsData.add(newPreset)
        resetAdditionDraft()
    }
}
