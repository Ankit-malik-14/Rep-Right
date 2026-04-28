import SwiftUI
import AVFoundation

enum JointTestPhase {
    case infoSheet
    case detectingPerson
    case timer
    case analyzing
}

struct JointModelTestScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ExerciseDetectionViewModel()
    @State private var phase: JointTestPhase = .infoSheet
    @State private var showSheet: Bool = true
    @State private var isFinishingSet = false
    
    var targetReps: Int? = nil
    var initialElapsedSeconds: Int = 0
    var onSetFinished: ((AssistanceSessionResult) -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Camera Feed
            if let session = viewModel.captureSession {
                JointModelCameraFeedView(session: session)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // Phase Overlays
            if phase == .detectingPerson {
                VStack {
                    Spacer()
                    Text(viewModel.currentPose.isValid ? "Person Detected" : "Step into frame...")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .padding()
                        .background(.black.opacity(0.6), in: Capsule())
                        .padding(.bottom, 50)
                }
                .onAppear {
                    if viewModel.currentPose.isValid {
                        startTimerPhase()
                    }
                }
                .onChange(of: viewModel.currentPose.isValid) { old, new in
                    if new {
                        startTimerPhase()
                    }
                }
            } else if phase == .timer {
                JointModelTimerOverlay(phase: $phase, viewModel: viewModel)
            } else if phase == .analyzing {
                // Skeleton Overlay
                PoseSkeletonView(
                    joints: viewModel.currentPose.joints,
                    isCorrect: viewModel.analysisResult?.isCorrect
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
                WorkoutCameraOverlayView(
                    repCount: viewModel.repCount,
                    targetReps: targetReps,
                    elapsedFormatted: viewModel.elapsedFormatted,
                    feedbackTitle: feedbackTitle,
                    feedbackMessage: feedbackMessage,
                    accentColor: .orange,
                    utilityIcon: "arrow.triangle.2.circlepath.camera.fill",
                    onUtilityTap: {
                        viewModel.toggleCamera()
                    },
                    onFinishTap: {
                        finishCurrentSet(autoCompleted: false)
                    }
                )
            }
        }
        .onAppear {
            // Default to Plank for testing
            viewModel.currentExerciseId = 1
            viewModel.initialElapsedSeconds = initialElapsedSeconds
            viewModel.elapsedSeconds = initialElapsedSeconds
            viewModel.elapsedFormatted = String(format: "%02d:%02d", initialElapsedSeconds / 60, initialElapsedSeconds % 60)
            viewModel.startCameraSession()
        }
        .onDisappear {
            viewModel.finishSetTracking()
            viewModel.stopCameraSession()
        }
        .sheet(isPresented: $showSheet, onDismiss: {
            phase = .detectingPerson
        }) {
            JointModelInfoSheet(showSheet: $showSheet)
                .presentationDetents([.fraction(0.7), .large])
                .interactiveDismissDisabled()
        }
        .onChange(of: viewModel.repCount) { _, newValue in
            guard phase == .analyzing,
                  let targetReps,
                  targetReps > 0,
                  newValue >= targetReps else { return }
            finishCurrentSet(autoCompleted: true)
        }
    }
    
    private func startTimerPhase() {
        // Wait 1 second before starting timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                self.phase = .timer
            }
        }
    }
    
    private var feedbackTitle: String? {
        guard let result = viewModel.analysisResult, !result.isCorrect else { return nil }
        return "Correction Needed"
    }
    
    private var feedbackMessage: String? {
        guard let result = viewModel.analysisResult, !result.isCorrect else { return nil }
        return result.flags.first ?? "Incorrect Posture"
    }
    
    private func finishCurrentSet(autoCompleted: Bool) {
        guard phase == .analyzing, !isFinishingSet else { return }
        isFinishingSet = true
        let completedReps = autoCompleted ? (targetReps ?? viewModel.repCount) : min(viewModel.repCount, targetReps ?? viewModel.repCount)
        onSetFinished?(AssistanceSessionResult(
            completedReps: completedReps,
            formAccuracy: viewModel.formAccuracyScore,
            formInsights: viewModel.topFormInsights
        ))
        viewModel.finishSetTracking()
        dismiss()
    }
}

struct JointModelInfoSheet: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Joint Model Testing")
                .font(.title2.bold())
                .padding(.top)
            
            HStack {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .frame(width: 80, height: 90)
                        Image(systemName: "figure.walk")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 50)
                    }
                    Text("Full body")
                        .font(.callout.bold())
                }
                .padding()
            }
            
            VStack {
                Text("This is an isolated test environment for the new dynamic joint-based posture model.")
                    .multilineTextAlignment(.center)
                    .padding()
                Text("Place the camera facing you sideways to test the Plank exercise.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            
            Spacer()
            
            Button {
                showSheet = false
            } label: {
                Text("Start Test")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button("Cancel", role: .cancel) {
                showSheet = false
            }
            .padding(.top, 8)
            .padding(.bottom)
        }
    }
}

struct JointModelTimerOverlay: View {
    @Binding var phase: JointTestPhase
    var viewModel: ExerciseDetectionViewModel
    @State private var timeRemaining = 3
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            Text("\(timeRemaining)")
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .animation(.easeInOut, value: timeRemaining)
        }
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                withAnimation {
                    viewModel.startSetTracking()
                    phase = .analyzing
                }
            }
        }
    }
}

struct JointModelCameraFeedView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct PoseSkeletonView: View {
    var joints: [String: BodyJoint]
    var isCorrect: Bool?
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Draw points
                ForEach(Array(joints.values), id: \.name) { joint in
                    Circle()
                        .fill(isCorrect == false ? Color.red : Color.green)
                        .frame(width: 10, height: 10)
                        .position(x: joint.point.x * geo.size.width,
                                  y: joint.point.y * geo.size.height)
                }
            }
        }
    }
}
