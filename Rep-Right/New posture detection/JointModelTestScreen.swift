import SwiftUI
import AVFoundation

enum JointTestPhase {
    case infoSheet
    case detectingPerson
    case timer
    case analyzing
}

struct JointModelTestScreen: View {
    @State private var viewModel = ExerciseDetectionViewModel()
    @State private var phase: JointTestPhase = .infoSheet
    @State private var showSheet: Bool = true
    
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
                JointModelTimerOverlay(phase: $phase)
            } else if phase == .analyzing {
                // Skeleton Overlay
                PoseSkeletonView(
                    joints: viewModel.currentPose.joints,
                    isCorrect: viewModel.analysisResult?.isCorrect
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
                // Live Feedback UI
                VStack {
                    Spacer()
                    if let result = viewModel.analysisResult {
                        VStack(spacing: 8) {
                            Text(result.exerciseName)
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            if result.isCorrect {
                                Text("Good Form")
                                    .font(.title3.bold())
                                    .foregroundStyle(.green)
                            } else {
                                Text(result.flags.first ?? "Incorrect Posture")
                                    .font(.title3.bold())
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding()
                        .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 15))
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            // Default to Plank for testing
            viewModel.currentExerciseId = 1
            viewModel.startCameraSession()
        }
        .onDisappear {
            viewModel.stopCameraSession()
        }
        .sheet(isPresented: $showSheet, onDismiss: {
            phase = .detectingPerson
        }) {
            JointModelInfoSheet(showSheet: $showSheet)
                .presentationDetents([.fraction(0.7), .large])
                .interactiveDismissDisabled()
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
