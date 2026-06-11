//
//  CaliberationScreen.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 22/03/26.
//

import SwiftUI

struct CaliberationScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showSheet: Bool = true
    @State private var detector = BackContourDetector()
    @State private var isFinishingSet = false
    
    var targetReps: Int? = nil
    var initialElapsedSeconds: Int = 0
    var onSetFinished: ((AssistanceSessionResult) -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Camera Feed
            CameraFeedView(session: detector.captureSession)
                .ignoresSafeArea()
            
            // Overlay based on phase
            if detector.phase == .detectingPerson {
                VStack {
                    Spacer()
                    Text(detector.detectionFeedback)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .padding()
                        .background(.black.opacity(0.6), in: Capsule())
                        .padding(.bottom, 50)
                }
            } else if detector.phase == .timer {
                AssistanceCountdownOverlay(
                    timeRemaining: detector.timerTime,
                    title: "Detection starting..."
                )
            } else if detector.phase == .analyzing {
                BackContourOverlayView(detector: detector)
                WorkoutCameraOverlayView(
                    repCount: detector.repCount,
                    targetReps: targetReps,
                    elapsedFormatted: detector.elapsedFormatted,
                    feedbackTitle: detector.isBackStraight ? nil : "Correction Needed",
                    feedbackMessage: detector.isBackStraight ? nil : detector.detectionFeedback,
                    accentColor: .orange,
                    utilityIcon: "arrow.triangle.2.circlepath.camera.fill",
                    onUtilityTap: {
                        detector.toggleCamera()
                    },
                    onFinishTap: {
                        finishCurrentSet(autoCompleted: false)
                    }
                )
            }
        }
        .onAppear {
            detector.initialElapsedSeconds = initialElapsedSeconds
            detector.elapsedSeconds = initialElapsedSeconds
            detector.elapsedFormatted = String(format: "%02d:%02d", initialElapsedSeconds / 60, initialElapsedSeconds % 60)
            detector.startSession()
        }
        .onDisappear {
            detector.stopSession()
        }
        .sheet(isPresented: $showSheet, onDismiss: {
            detector.startDetectingPerson()
        }) {
            AssistanceSetupSheet(
                showSheet: $showSheet,
                title: "Back Contour Assistance",
                primaryButtonTitle: "Continue",
                headline: "Set your camera before calibration begins.",
                detail: "For this exercise, place the camera from the side so your full body stays visible in frame.",
                steps: [
                    AssistanceSetupStep(title: "Hip Height", systemImage: "lines.measurement.vertical"),
                    AssistanceSetupStep(title: "Full body", systemImage: "figure.stand"),
                    AssistanceSetupStep(title: "6-8 feet", systemImage: "ruler")
                ]
            )
                .presentationDetents([.custom(CustomDetents.self), .large])
                .interactiveDismissDisabled() // Force user to tap Continue
        }
        .onChange(of: detector.repCount) { _, newValue in
            guard detector.phase == .analyzing,
                  let targetReps,
                  targetReps > 0,
                  newValue >= targetReps else { return }
            finishCurrentSet(autoCompleted: true)
        }
    }
    
    private func finishCurrentSet(autoCompleted: Bool) {
        guard detector.phase == .analyzing, !isFinishingSet else { return }
        isFinishingSet = true
        let completedReps = autoCompleted ? (targetReps ?? detector.repCount) : min(detector.repCount, targetReps ?? detector.repCount)
        onSetFinished?(AssistanceSessionResult(
            completedReps: completedReps,
            formAccuracy: detector.formAccuracyScore,
            formInsights: detector.topFormInsights
        ))
        detector.finishSet()
        dismiss()
    }
}

struct AssistanceSetupStep: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
}

struct AssistanceSetupSheet: View {
    @Binding var showSheet: Bool
    let title: String
    let primaryButtonTitle: String
    let headline: String
    let detail: String
    let steps: [AssistanceSetupStep]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                Text(headline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                ForEach(steps) { step in
                    VStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(.tertiarySystemFill))
                            .frame(maxWidth: .infinity)
                            .frame(height: 92)
                            .overlay {
                                Image(systemName: step.systemImage)
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundStyle(.orange)
                            }
                        Text(step.title)
                            .font(.callout.weight(.semibold))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Label("Wear fitted clothing for better accuracy.", systemImage: "tshirt")
                Text(detail)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            
            Text("Scanning Environment...")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Button {
                showSheet = false
            } label: {
                Text(primaryButtonTitle)
            }
            .buttonStyle(AppPrimaryButtonStyle())
            
            Button("Cancel", role: .cancel) {
                showSheet = false
            }
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

struct AssistanceCountdownOverlay: View {
    let timeRemaining: Int
    let title: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.34).ignoresSafeArea()
            
            VStack(spacing: 28) {
                Text("\(timeRemaining)")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
                    .monospacedDigit()
                
                VStack(spacing: 18) {
                    Text(title)
                        .font(.headline)
                    
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { index in
                            Capsule()
                                .fill(index < 3 - timeRemaining ? Color.orange : Color.orange.opacity(0.25))
                                .frame(width: 72, height: 8)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 22)
                .frame(maxWidth: 320)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .padding(.horizontal, 24)
        }
    }
}

struct CustomDetents: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        context.maxDetentValue - 250
    }
}

#Preview {
    CaliberationScreen()
}
