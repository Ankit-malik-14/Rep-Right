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
                CalibrationScreen2(detector: detector)
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
            CaliberationSheetView(showSheet: $showSheet)
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

struct CaliberationSheetView: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                //hip height
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width: 80, height: 90)
                        Image(systemName: "lines.measurement.vertical")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 50)
                    }
                    Text("Hip Height")
                        .font(.callout.bold())
                }
                .padding()
                
                //full body
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width: 80, height: 90)
                        Image(systemName: "rectangle.dashed")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .rotationEffect(Angle(degrees: 90))
                        Image(systemName: "figure")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 30)
                    }
                    Text("Full body")
                        .font(.callout.bold())
                }
                .padding()
                
                //6-8 feet
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width: 80, height: 90)
                        Image(systemName: "ruler")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    Text("6-8 feet")
                        .font(.callout.bold())
                }
                .padding()
            }
            
            //Text information
            VStack {
                Text("Wear body hugging clothes for better accuracy")
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                Text("For this exercise place camera facing sideways")
            }
            .padding(10)
            
            Text("Scanning Environment...")
                .bold()
                .padding(10)
            
            Button {
                showSheet = false
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button("Cancel", role: .cancel) {
                showSheet = false
            }.tint(.orange)
                .padding(.top, 8)
        }
        .padding()
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
