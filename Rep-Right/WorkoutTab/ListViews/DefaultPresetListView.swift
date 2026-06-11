//
//  DefaultPresetListView.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-25.
//

import SwiftUI

struct DefaultPresetListView: View {
    var presets: Presets
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(presets.presets) { preset in
                    NavigationLink(value: WorkoutRoute.presetDetail(preset)) {
                        PresetTileViewType(preset: preset, type: .large)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .navigationTitle("Presets")
        }
    }
}

#Preview {
    NavigationStack{
        DefaultPresetListView(presets: Presets())
            .environment(Presets())
    }
}
