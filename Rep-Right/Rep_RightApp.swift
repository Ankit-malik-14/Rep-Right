//
//  Rep_RightApp.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-16.
//

import SwiftUI

@main
struct Rep_RightApp: App {
    var presets = Presets()

    var body: some Scene {
        WindowGroup {
            WorkoutScreen()
                .environment(presets)
                
        }
    }
}
