//
//  CustomPresetsListView.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPresetsListView: View {
    @Environment(CustomPresetsViewModel.self) private var viewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        @Bindable var viewModel = viewModel
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.customPresets) { preset1 in
                    Group {
                        if viewModel.isSelectionMode {
                            Button {
                                viewModel.toggleSelection(for: preset1)
                            } label: {
                                PresetTileViewType(
                                    preset: preset1,
                                    type: .large,
                                    showsSelection: true,
                                    isSelected: viewModel.selectedPresetIDs.contains(preset1.id)
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
                    if !viewModel.customPresets.isEmpty {
                        Button(viewModel.isSelectionMode ? "Cancel" : "Select") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.isSelectionMode.toggle()
                                if !viewModel.isSelectionMode {
                                    viewModel.selectedPresetIDs.removeAll()
                                }
                            }
                        }
                    }
                    
                    if !viewModel.isSelectionMode {
                        Button {
                            viewModel.showAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.isSelectionMode {
                    Button(role: .destructive) {
                        viewModel.deleteSelectedPresets()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(viewModel.selectedPresetIDs.isEmpty)
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            CustomPresetAdditionView(isPresented: $viewModel.showAddSheet)
                .environment(viewModel)
        }
    }
}

#Preview {
    let customPresetsData = CustomPresetsDummyData()
    let exercises = Exercises()
    let viewModel = CustomPresetsViewModel(customPresetsData: customPresetsData, exercises: exercises)
    
    return NavigationStack {
        CustomPresetsListView()
            .environment(viewModel)
    }
}

