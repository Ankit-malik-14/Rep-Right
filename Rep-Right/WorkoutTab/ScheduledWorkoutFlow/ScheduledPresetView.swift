//
//  ScheduledPresetView.swift
//  PresettFlow
//
//  Created by Jugad on 17/03/26.
//

import SwiftUI

//routes for this flow
enum Route: Hashable {
    case workoutDetail
    case warmup
    case exercise(Exercise)
}

// MARK: Preset Flow(Entry Point)
struct ScheduledPresetView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Home Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                // type-safe NavigationLink using Route enum
                NavigationLink(value: Route.workoutDetail) {
                    Text("Go to Back Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 250)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
            //destination handling for the entire flow
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .workoutDetail:
                    PresetDetailView()
                case .warmup:
                    WarmUpView()
                case .exercise(let exercise):
                    ExerciseDetailView(exercise: exercise)
                }
            }
        }
    }
}

// MARK: - Exercise Detail Page (Destination)

struct ScheduledPresetView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledPresetView()
    }
}
