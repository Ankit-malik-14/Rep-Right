//
//  CustomPresetsListView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPresetsListView: View {
    var preset: CustomPresetsDummyData
    @State private var showAddSheet = false
    @State private var isSelectionMode = false
    @State private var selectedPresetIDs = Set<UUID>()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(preset.customPresets) { preset1 in
                    Group {
                        if isSelectionMode {
                            Button {
                                toggleSelection(for: preset1)
                            } label: {
                                PresetTileViewType(
                                    preset: preset1,
                                    type: .large,
                                    showsSelection: true,
                                    isSelected: selectedPresetIDs.contains(preset1.id)
                                )
                            }
                        } else {
                            NavigationLink(value: WorkoutRoute.presetDetail(preset1)) {
                                PresetTileViewType(preset: preset1, type: .large)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .navigationTitle("Custom")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 14) {
                    if !preset.customPresets.isEmpty {
                        Button(isSelectionMode ? "Cancel" : "Select") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isSelectionMode.toggle()
                                if !isSelectionMode {
                                    selectedPresetIDs.removeAll()
                                }
                            }
                        }
                    }
                    
                    if !isSelectionMode {
                        Button {
                            showAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                if isSelectionMode {
                    Button(role: .destructive) {
                        deleteSelectedPresets()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(selectedPresetIDs.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            CustomPresetAdditionView(isPresented: $showAddSheet)
        }
    }
    
    private func toggleSelection(for preset: Preset) {
        if selectedPresetIDs.contains(preset.id) {
            selectedPresetIDs.remove(preset.id)
        } else {
            selectedPresetIDs.insert(preset.id)
        }
    }
    
    private func deleteSelectedPresets() {
        preset.customPresets.removeAll { selectedPresetIDs.contains($0.id) }
        selectedPresetIDs.removeAll()
        isSelectionMode = false
    }
}

#Preview {
    NavigationStack {
        CustomPresetsListView(preset: CustomPresetsDummyData())
            .environment(CustomPresetsDummyData())
    }
}
