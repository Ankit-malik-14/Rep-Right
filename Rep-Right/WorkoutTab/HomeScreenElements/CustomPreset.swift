//
//  CustomPreset.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct CustomPreset: View {
    @Environment(CustomPresetsViewModel.self) private var viewModel
    @State var showScreen = false
    
    var body: some View {
        @Bindable var viewModel = viewModel
        if viewModel.customPresets.count == 0 {
            VStack(alignment: .leading) {
                // Text Content
                VStack(alignment: .leading, spacing: 6) {
                    Text("Create custom presets")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("You can create a custom workout preset as per your needs.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 12)
                
                // Action Button
                Button(action: {
                    showScreen.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.badge.plus")
                            .font(.footnote)
                        
                        Text("Create Preset")
                            .font(.footnote)
                    }
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .popover(isPresented: $showScreen) {
                    CustomPresetAdditionView(isPresented: $showScreen)
                        .environment(viewModel)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(UIColor.systemGray6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
        }
        else {
            VStack(spacing: 5) {
                HStack {
                    NavigationLink(value: WorkoutRoute.customPresetsList) {
                        HStack {
                            Text("Custom Presets")
                                .foregroundStyle(.black)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .tint(.orange)
                                .padding(.top, 4)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(viewModel.customPresets.prefix(3))) { customPreset in
                            NavigationLink(value: WorkoutRoute.presetDetail(customPreset)) {
                                PresetTileViewType(preset: customPreset, type: .large)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    CustomPreset()
        .environment(CustomPresetsViewModel(
            customPresetsData: CustomPresetsDummyData(),
            exercises: Exercises()
        ))
}

