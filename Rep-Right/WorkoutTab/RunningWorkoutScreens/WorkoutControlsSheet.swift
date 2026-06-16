//
//  WorkoutControlsSheet.swift
//  Rep-Right
//

import SwiftUI

struct WorkoutControlsSheet: View {
    @Bindable var manager: WorkoutSessionManager
    @Binding var selectedDetent: PresentationDetent
    @Binding var showCalibration: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Header
            VStack(spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(manager.currentExercise?.name ?? "Exercise")
                            .font(.title3.bold())
                        Text(manager.currentSetLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Live stopwatch — driven by TimelineView for jank-free updates
                    TimelineView(.periodic(from: .now, by: 1.0)) { _ in
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundStyle(.orange)
                            Text(manager.elapsedTimeFormatted)
                                .font(.headline.monospacedDigit())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // MARK: - SF Symbol Controls
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Pause / Resume
                    Button {
                        manager.toggleTimer()
                    } label: {
                        Label(
                            manager.isTimerRunning ? "Pause" : "Resume",
                            systemImage: manager.isTimerRunning ? "pause.fill" : "play.fill"
                        )
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .foregroundStyle(.orange)
                    
                    // Assistance
                    Button {
                        showCalibration = true
                    } label: {
                        Label("Assistance", systemImage: "figure.walk.motion")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .foregroundStyle(.blue)
                    .disabled(!(manager.currentExercise?.assistanceAvailable ?? false))
                    .opacity((manager.currentExercise?.assistanceAvailable ?? false) ? 1 : 0.45)
                }
                
                HStack(spacing: 12) {
                    // Skip Exercise
                    Button {
                        manager.skipExercise()
                    } label: {
                        Label("Skip", systemImage: "forward.fill")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .foregroundStyle(.orange)
                    
                    // Finish Workout
                    Button {
                        manager.finishWorkout()
                    } label: {
                        Label("Finish", systemImage: "stop.fill")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .foregroundStyle(.red)
                }
            }
            .padding(.horizontal)
            
            // MARK: - Interactive Sets Table (visible only when expanded)
            if selectedDetent == .medium {
                Divider().padding(.horizontal)
                
                VStack(spacing: 0) {
                    // Table header
                    HStack {
                        Text("Set")
                            .frame(width: 36)
                        Text("Reps")
                            .frame(maxWidth: .infinity)
                        Text("Weight")
                            .frame(maxWidth: .infinity)
                        Text("")
                            .frame(width: 44)
                    }
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                    
                    // Set rows with checkmark toggles
                    ForEach($manager.currentSets) { $setEntry in
                        HStack {
                            Text("\(setEntry.setNumber)")
                                .font(.headline)
                                .frame(width: 36)
                                .foregroundStyle(setEntry.isCompleted ? .green : .primary)
                            
                            TextField("reps", text: $setEntry.reps)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .disabled(setEntry.isCompleted)
                            
                            TextField("kg", text: $setEntry.weight)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .disabled(setEntry.isCompleted)
                            
                            // Apple-style checkmark toggle
                            Button {
                                withAnimation(.spring(duration: 0.3)) {
                                    manager.toggleSetComplete(id: setEntry.id)
                                }
                            } label: {
                                Image(systemName: setEntry.isCompleted
                                      ? "checkmark.circle.fill"
                                      : "circle")
                                    .font(.title2)
                                    .foregroundStyle(setEntry.isCompleted ? .green : .gray.opacity(0.4))
                                    .contentTransition(.symbolEffect(.replace))
                            }
                            .frame(width: 44)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            setEntry.isCompleted
                            ? Color.green.opacity(0.06)
                            : .clear,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.top)
        .fullScreenCover(isPresented: $showCalibration) {
            Group {
                if let exercise = manager.currentExercise {
                    if exercise.assistanceModel == .joint {
                        JointModelTestScreen(
                            exerciseName: exercise.name,
                            exerciseRuleID: exercise.assistanceRuleID,
                            exerciseRuleName: exercise.assistanceRuleName,
                            usesStaticHoldProgress: exercise.assistanceUsesStaticHold,
                            targetReps: manager.currentActiveSetTargetReps,
                            initialElapsedSeconds: Int(manager.elapsedTime),
                            onSetFinished: { result in
                                manager.recordAssistanceResult(result)
                            }
                        )
                    } else {
                        CaliberationScreen(
                            exerciseName: exercise.name,
                            targetReps: manager.currentActiveSetTargetReps,
                            initialElapsedSeconds: Int(manager.elapsedTime),
                            onSetFinished: { result in
                                manager.recordAssistanceResult(result)
                            }
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    WorkoutControlsSheet(manager: {
        let m = WorkoutSessionManager(preset: Presets().presets[0])
        m.startWorkout()
        return m
    }(), selectedDetent: .constant(.medium), showCalibration: .constant(false))
}
