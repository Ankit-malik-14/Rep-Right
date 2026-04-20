//
//  IndividualRunningExerciseView.swift
//  Rep-Right
//

import SwiftUI

struct IndividualRunningExerciseView: View {
    // Fetched from DataModel: the exercise being performed
    var exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    
    // Fetched from environments to log completed session
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(UserProfileModel.self) private var userProfile
    
    // MARK: - Timer State
    @State private var timeElapsed: TimeInterval = 0
    @State private var isRunning = false
    @State private var timer: Timer?
    
    // MARK: - Sets State
    @State private var sets: [WorkoutSet] = []
    @State private var showEndConfirmation = false
    
    // Formatted stopwatch string (MM:SS.cc)
    private var stopwatchDisplay: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        let centiseconds = Int((timeElapsed.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - Stopwatch Section (Apple Fitness style)
                VStack(spacing: 8) {
                    // Fetched from DataModel: exercise.name
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    // Large stopwatch display
                    Text(stopwatchDisplay)
                        .font(.system(size: 64, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                    
                    // Fetched from DataModel: exercise.targetAreas
                    HStack(spacing: 16) {
                        Label(exercise.targetAreas.first ?? "--", systemImage: "figure.strengthtraining.traditional")
                        if let equipment = exercise.equipments.first {
                            Label(equipment, systemImage: "dumbbell.fill")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                Divider().padding(.horizontal)
                
                // MARK: - AI / Image Section
                // Fetched from DataModel: exercise.assistanceAvailable
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.ultraThinMaterial)
                        .frame(height: 200)
                    
                    if exercise.assistanceAvailable {
                        // AI Assistance is available → show model placeholder
                        VStack(spacing: 10) {
                            Image(systemName: "figure.walk.motion")
                                .font(.system(size: 50))
                                .foregroundStyle(.orange)
                                .symbolEffect(.pulse, isActive: isRunning)
                            Text("Model Here")
                                .font(.title3.bold())
                                .foregroundStyle(.primary)
                            Text("AI posture tracking active")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        // AI not available → show exercise image placeholder
                        VStack(spacing: 10) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.gray.opacity(0.5))
                            Text("Exercise Preview")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                // MARK: - Sets Section
                ScrollView {
                    VStack(spacing: 8) {
                        // Header
                        HStack {
                            Text("Set").font(.caption.bold()).foregroundStyle(.secondary).frame(width: 40)
                            Text("Weight").font(.caption.bold()).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                            Text("Reps").font(.caption.bold()).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 24)
                        
                        // Fetched from DataModel: exercise.setData mapped to editable rows
                        ForEach($sets) { $workoutSet in
                            HStack {
                                Text("\(workoutSet.setNumber)")
                                    .font(.headline)
                                    .frame(width: 40)
                                TextField("kg", text: $workoutSet.weight)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                TextField("reps", text: $workoutSet.reps)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Add set button
                        Button {
                            let next = (sets.last?.setNumber ?? 0) + 1
                            sets.append(WorkoutSet(
                                setNumber: next,
                                weight: sets.last?.weight ?? "0",
                                reps: sets.last?.reps ?? "8"
                            ))
                        } label: {
                            Label("Add Set", systemImage: "plus")
                                .font(.subheadline.bold())
                                .foregroundStyle(.orange)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(.background.secondary))
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 8)
                }
                
                Divider()
                
                // MARK: - Controls (Apple Fitness style)
                HStack(spacing: 20) {
                    // End button
                    Button {
                        showEndConfirmation = true
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(.red.opacity(0.15))
                            Image(systemName: "stop.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    // Play / Pause toggle
                    Button {
                        if isRunning {
                            pauseTimer()
                        } else {
                            startTimer()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 85, height: 85)
                                .foregroundStyle(.orange)
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                    }
                    
                    // Lap / Reset
                    Button {
                        timeElapsed = 0
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(.background.secondary)
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title2)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showEndConfirmation = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("End Session?", isPresented: $showEndConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("End", role: .destructive) {
                    stopTimer()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to end this workout session?")
            }
        }
        .onAppear {
            // Fetched from DataModel: exercise.setData to populate editable set rows
            self.sets = exercise.setData.enumerated().map { (index, data) in
                WorkoutSet(setNumber: index + 1, weight: "0", reps: "\(data.reps)")
            }
            if self.sets.isEmpty {
                self.sets.append(WorkoutSet(setNumber: 1, weight: "0", reps: "8"))
            }
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Timer Functions
    
    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            timeElapsed += 0.01
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func stopTimer() {
        pauseTimer()
        
        let weight = userProfile.weight
        let cals = summaryManager.calculateCalories(for: exercise, durationInSeconds: timeElapsed, weightInKg: weight)
        
        let mappedSets = sets.map { SetData(sets: 1, reps: Int($0.reps) ?? 0) }
        
        summaryManager.logStandaloneExercise(
            exerciseId: exercise.id,
            actualSet: mappedSets,
            startTime: Date().addingTimeInterval(-timeElapsed),
            endTime: Date(),
            caloriesBurned: cals
        )
        
        timeElapsed = 0
    }
}

#Preview {
    IndividualRunningExerciseView(exercise: Exercises().exerciseList[0])
        .environment(WorkoutSummaryManager())
        .environment(UserProfileModel())
}
