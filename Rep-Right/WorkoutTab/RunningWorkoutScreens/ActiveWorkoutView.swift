//
//  ActiveWorkoutView.swift
//  Rep-Right
//

import SwiftUI
import AVKit

// MARK: - Looping Video Player (UIViewRepresentable)

class LoopingPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?
    
    init(url: URL) {
        super.init(frame: .zero)
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(items: [item])
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        player = queuePlayer
        
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        queuePlayer.isMuted = true
        queuePlayer.play()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    func cleanup() {
        player?.pause()
        player = nil
        playerLooper = nil
    }
}

struct LoopingVideoPlayer: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> LoopingPlayerUIView {
        LoopingPlayerUIView(url: url)
    }
    
    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {}
    
    static func dismantleUIView(_ uiView: LoopingPlayerUIView, coordinator: ()) {
        uiView.cleanup()
    }
}

// MARK: - Exercise Background (Video + Animated Fallback)

struct ExerciseBackground: View {
    let exercise: Exercise
    @State private var animatePulse = false
    
    var body: some View {
        ZStack {
            // Deep gradient base
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.10),
                    Color(red: 0.14, green: 0.07, blue: 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated pulse rings
            ForEach(0..<3, id: \.self) { ring in
                Circle()
                    .stroke(
                        Color.orange.opacity(0.12 - Double(ring) * 0.03),
                        lineWidth: 1.5
                    )
                    .frame(width: 180 + CGFloat(ring) * 90)
                    .scaleEffect(animatePulse ? 1.4 : 0.8)
                    .opacity(animatePulse ? 0 : 0.7)
                    .animation(
                        .easeOut(duration: 3.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(ring) * 0.6),
                        value: animatePulse
                    )
            }
            
            // Center figure icon (visible when video doesn't load)
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 90, weight: .ultraLight))
                .foregroundStyle(
                    .linearGradient(
                        colors: [.orange.opacity(0.4), .orange.opacity(0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Video layer (plays over gradient when URL loads)
            if let url = exercise.demoVideo {
                LoopingVideoPlayer(url: url)
                    .ignoresSafeArea()
                    .opacity(0.85)
            }
            
            // Bottom gradient for sheet readability
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 280)
            }
            .ignoresSafeArea()
            
            // Top status bar
            VStack {
                exerciseStatusBar
                    .padding(.top, 60)
                Spacer()
            }
        }
        .onAppear { animatePulse = true }
    }
    
    private var exerciseStatusBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "figure.strengthtraining.traditional")
                .foregroundStyle(.orange)
            Text(exercise.name)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
            
            Spacer()
            
            if let area = exercise.targetAreas.first {
                Text(area)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.orange.opacity(0.25), in: Capsule())
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Active Workout View (Main Container)

struct ActiveWorkoutView: View {
    let preset: Preset
    @State private var manager: WorkoutSessionManager
    @State private var showSheet = false
    @State private var countdownValue = 3
    @State private var selectedDetent: PresentationDetent = .fraction(0.1)
    
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    // UPDATED: Changed from struct environment key to @Observable tracking
    @Environment(UserProfileModel.self) private var userProfile
    @Environment(WorkoutRouter.self) private var router
    
    init(preset: Preset) {
        self.preset = preset
        self._manager = State(initialValue: WorkoutSessionManager(preset: preset))
    }
    
    var body: some View {
        // TimelineView drives elapsed-time recalculation every second
        // without blocking the main thread (replaces Timer.scheduledTimer)
        TimelineView(.periodic(from: .now, by: 1.0)) { _ in
            ZStack {
                Color.black.ignoresSafeArea()
                
                switch manager.phase {
                case .preparing:
                    preparingView
                        .transition(.opacity)
                    
                case .activeExercise(let exercise):
                    ExerciseBackground(exercise: exercise)
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                    
                case .resting:
                    WorkoutRestScreen(manager: manager)
                        .transition(.opacity)
                    
                case .finished:
                    finishedView
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: manager.phase)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showSheet) {
                WorkoutControlsSheet(manager: manager, selectedDetent: $selectedDetent)
                    .presentationDetents([.fraction(0.2), .medium], selection: $selectedDetent)
                    .presentationBackground(.ultraThinMaterial)
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
                    .interactiveDismissDisabled()
            }
            .onChange(of: manager.phase) { _, newPhase in
                handlePhaseChange(newPhase)
            }
        }
    }
    
    // MARK: - Preparing View (3-2-1 Countdown)
    
    private var preparingView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.1), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(preset.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(0.6))
                
                Text("\(countdownValue)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.4), value: countdownValue)
                
                Text("GET READY")
                    .font(.title3.bold())
                    .tracking(4)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .onAppear { startCountdown() }
    }
    
    // MARK: - Finished View (Completion Summary)
    
    private var finishedView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.08, blue: 0.02), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: true)
                
                Text("Workout Complete!")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                
                HStack(spacing: 30) {
                    statColumn(
                        value: manager.elapsedTimeFormatted,
                        label: "Duration"
                    )
                    // UPDATED: Use userProfile.weight value natively
                    statColumn(
                        value: "\(manager.estimatedCalories(userWeightKg: userProfile.weight))",
                        label: "Calories"
                    )
                    statColumn(
                        value: "\(manager.completedExerciseCount)",
                        label: "Exercises"
                    )
                }
                .padding(.top, 10)
            }
        }
    }
    
    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold().monospacedDigit())
                .foregroundStyle(.orange)
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
    
    // MARK: - Logic
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownValue > 1 {
                countdownValue -= 1
            } else {
                timer.invalidate()
                manager.startWorkout()
            }
        }
    }
    
    private func handlePhaseChange(_ newPhase: WorkoutPhase) {
        switch newPhase {
        case .activeExercise:
            if !showSheet {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    showSheet = true
                }
            }
        case .resting:
            showSheet = false
        case .finished:
            showSheet = false
            logSession()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                router.popToRoot()
            }
        case .preparing:
            showSheet = false
        }
    }
    
    // UPDATED: Logs only exercises the user actually attempted (up to currentIndex),
    // using each exercise's own archived sets, filtered to completed-only.
    private func logSession() {
        let weight = userProfile.weight
        
        // Archive the current exercise's sets before building the log
        manager.archiveCurrentSets()
        
        // Only consider exercises up to (and including) the one the user was on
        let attemptedCount = manager.currentIndex + 1
        let attemptedExercises = Array(manager.exerciseQueue.prefix(attemptedCount))
        let count = max(attemptedExercises.count, 1)
        let timePerExercise = manager.elapsedTime / Double(count)
        
        let exerciseData: [(exerciseId: UUID, actualSet: [SetData], startTime: Date, endTime: Date, caloriesBurned: Double?)] = attemptedExercises.enumerated().compactMap { idx, exercise in
            // Retrieve this exercise's archived sets (not the current exercise's sets)
            let archived = manager.completedSetsArchive[idx] ?? []
            let completedOnly = archived.filter(\.isCompleted)
            
            // Skip exercises where the user completed zero sets
            guard !completedOnly.isEmpty else { return nil }
            
            let cals = summaryManager.calculateCalories(
                for: exercise,
                durationInSeconds: timePerExercise,
                weightInKg: weight
            )
            let setData = completedOnly.map {
                SetData(sets: 1, reps: Int($0.reps) ?? $0.targetReps)
            }
            return (
                exerciseId: exercise.id,
                actualSet: setData,
                startTime: Date().addingTimeInterval(-manager.elapsedTime),
                endTime: Date(),
                caloriesBurned: Optional(cals)
            )
        }
        summaryManager.logPresetSession(presetId: preset.id, exercises: exerciseData)
    }
}

#Preview {
    NavigationStack {
        // UPDATED: Inject UserProfileModel via environment instead of dummy profile
        ActiveWorkoutView(preset: Presets().presets[0])
            .environment(WorkoutSummaryManager())
            .environment(UserProfileModel())
            .environment(WorkoutRouter())
    }
}
