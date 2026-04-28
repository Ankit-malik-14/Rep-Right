////
////  PostureCheckView.swift
////  Rep_Right
////
////  Created by Mayurakshi Das on 25/04/26.
////
//
////import SwiftUI
////import AVFoundation
////
////// MARK: - PostureCheckView
////
////struct PostureCheckView: View {
////    var exercise: Exercise
////
////    @State private var viewModel = ExerciseDetectionViewModel()
////    @Environment(\.dismiss) private var dismiss
////
////    // MARK: - Exercise ID Mapping
////    private var exerciseId: Int {
////        switch exercise.name {
////        case "Plank":               return 1
////        case "Wall Sit":            return 2
////        case "Bodyweight Squat":    return 3
////        case "Glute Bridge Hold":   return 4
////        case "Dead Hang":           return 5
////        case "Overhead Hold":       return 6
////        case "Push-Up":             return 7
////        case "Forearm Plank":       return 8
////        case "Side Plank":          return 9
////        case "Lunge Hold":          return 10
////        case "Hip Abduction Hold":  return 11
////        case "L-Sit Hold":          return 12
////        case "Hollow Body Hold":    return 13
////        case "Superman Hold":       return 14
////        default:                    return 1
////        }
////    }
////
////    private var formPercent: Double {
////        Double(viewModel.analysisResult?.confidence ?? 0) * 100
////    }
////
////    private var accuracyColor: Color {
////        if formPercent >= 75 { return .green }
////        if formPercent >= 40 { return .orange }
////        return .red
////    }
////
////    // MARK: - Body
////    var body: some View {
////        ZStack {
////
////            // LAYER 1 — Camera feed
////            CameraFeedView(viewModel: viewModel)
////                .ignoresSafeArea()
////
////            // LAYER 2 — Skeleton overlay
////            PoseSkeletonView(
////                joints: viewModel.currentPose.joints,
////                isCorrect: viewModel.analysisResult?.isCorrect
////            )
////            .ignoresSafeArea()
////            .allowsHitTesting(false)
////
////            // LAYER 3 — UI controls
////            VStack(spacing: 0) {
////
////                // Top bar
////                HStack {
////                    Button {
////                        viewModel.stopCameraSession()
////                        dismiss()
////                    } label: {
////                        Image(systemName: "xmark.circle.fill")
////                            .font(.title)
////                            .foregroundStyle(.white)
////                            .shadow(color: .black.opacity(0.4), radius: 4)
////                    }
////                    .padding()
////                    .accessibilityLabel("Close posture check")
////
////                    Spacer()
////
////                    if viewModel.isAnalyzing {
////                        LivePillView()
////                            .padding()
////                    }
////                }
////
////                Spacer()
////
////                // Bottom feedback card
////                FeedbackCardView(
////                    exerciseName: exercise.name,
////                    formPercent: formPercent,
////                    accuracyColor: accuracyColor,
////                    analysisResult: viewModel.analysisResult,
////                    cameraPermissionGranted: viewModel.cameraPermissionGranted
////                )
////                .padding(.horizontal, 16)
////                .padding(.bottom, 24)
////            }
////        }
////        .ignoresSafeArea(edges: .top)
////        .onAppear {
////            viewModel.setCurrentExercise(id: exerciseId)
////            viewModel.startCameraSession()
////        }
////        .onDisappear {
////            viewModel.stopCameraSession()
////        }
////    }
////}
////
////// MARK: - Live Pill
////
////private struct LivePillView: View {
////    @State private var pulse = false
////
////    var body: some View {
////        HStack(spacing: 5) {
////            Circle()
////                .fill(.red)
////                .frame(width: 8, height: 8)
////                .scaleEffect(pulse ? 1.3 : 1.0)
////                .animation(
////                    .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
////                    value: pulse
////                )
////            Text("LIVE")
////                .font(.caption.bold())
////                .foregroundStyle(.white)
////        }
////        .padding(.horizontal, 10)
////        .padding(.vertical, 5)
////        .background(.black.opacity(0.5), in: Capsule())
////        .onAppear { pulse = true }
////    }
////}
////
////// MARK: - Feedback Card
////
////private struct FeedbackCardView: View {
////    let exerciseName: String
////    let formPercent: Double
////    let accuracyColor: Color
////    let analysisResult: ExerciseAnalysisResult?
////    let cameraPermissionGranted: Bool
////
////    var body: some View {
////        VStack(alignment: .leading, spacing: 14) {
////
////            // Exercise name + score
////            HStack {
////                Text(exerciseName)
////                    .font(.title3.bold())
////                    .foregroundStyle(.white)
////                Spacer()
////                Text("\(Int(formPercent))%")
////                    .font(.title2.bold())
////                    .foregroundStyle(accuracyColor)
////                    .contentTransition(.numericText())
////                    .animation(.easeOut(duration: 0.3), value: formPercent)
////            }
////
////            // Progress bar
////            GeometryReader { geo in
////                ZStack(alignment: .leading) {
////                    Capsule()
////                        .fill(.white.opacity(0.2))
////                        .frame(height: 8)
////                    Capsule()
////                        .fill(accuracyColor)
////                        .frame(
////                            width: geo.size.width * min(formPercent / 100.0, 1.0),
////                            height: 8
////                        )
////                        .animation(.easeOut(duration: 0.35), value: formPercent)
////                }
////            }
////            .frame(height: 8)
////
////            // Status row
////            if let result = analysisResult {
////                HStack(spacing: 6) {
////                    Image(
////                        systemName: result.isCorrect
////                            ? "checkmark.seal.fill"
////                            : "exclamationmark.triangle.fill"
////                    )
////                    .foregroundStyle(result.isCorrect ? .green : .orange)
////
////                    Text(result.isCorrect ? "Good Form" : "Needs Correction")
////                        .font(.subheadline.bold())
////                        .foregroundStyle(.white)
////                }
////            } else {
////                Text("Step in front of the camera…")
////                    .font(.subheadline)
////                    .foregroundStyle(.white.opacity(0.6))
////            }
////
////            Divider()
////                .overlay(.white.opacity(0.25))
////
////            // Flags
////            if let result = analysisResult {
////                if result.flags.isEmpty {
////                    HStack(spacing: 8) {
////                        Image(systemName: "checkmark.circle.fill")
////                            .foregroundStyle(.green)
////                        Text("No issues detected. Keep it up!")
////                            .font(.subheadline)
////                            .foregroundStyle(.white)
////                    }
////                } else {
////                    ScrollView(.vertical, showsIndicators: false) {
////                        VStack(alignment: .leading, spacing: 8) {
////                            ForEach(result.flags, id: \.self) { flag in
////                                HStack(alignment: .top, spacing: 8) {
////                                    Image(systemName: "exclamationmark.circle.fill")
////                                        .foregroundStyle(.orange)
////                                        .font(.subheadline)
////                                    Text(flag)
////                                        .font(.subheadline)
////                                        .foregroundStyle(.white)
////                                    Spacer()
////                                }
////                            }
////                        }
////                    }
////                    .frame(maxHeight: 120)
////                }
////            }
////
////            // Camera permission warning
////            if !cameraPermissionGranted {
////                HStack(spacing: 8) {
////                    Image(systemName: "camera.fill")
////                        .foregroundStyle(.red)
////                    Text("Camera access denied. Enable it in Settings.")
////                        .font(.caption)
////                        .foregroundStyle(.red)
////                }
////            }
////        }
////        .padding(20)
////        .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 24))
////    }
////}
////
////// MARK: - Pose Skeleton Overlay
////
////struct PoseSkeletonView: View {
////    let joints: [String: BodyJoint]
////    let isCorrect: Bool?
////
////    private let connections: [(String, String)] = [
////        ("nose", "right_eye"),       ("nose", "left_eye"),
////        ("right_eye", "right_ear"),  ("left_eye", "left_ear"),
////        ("nose", "neck"),
////        ("neck", "right_shoulder"),  ("neck", "left_shoulder"),
////        ("right_shoulder", "right_elbow"), ("right_elbow", "right_wrist"),
////        ("left_shoulder", "left_elbow"),   ("left_elbow", "left_wrist"),
////        ("right_shoulder", "right_hip"),   ("left_shoulder", "left_hip"),
////        ("right_hip", "left_hip"),
////        ("right_hip", "right_knee"),  ("right_knee", "right_ankle"),
////        ("left_hip", "left_knee"),    ("left_knee", "left_ankle")
////    ]
////
////    private var boneColor: Color {
////        guard let correct = isCorrect else { return .yellow }
////        return correct ? .green : .orange
////    }
////
////    var body: some View {
////        Canvas { context, size in
////
////            // Draw bones
////            for (startName, endName) in connections {
////                guard
////                    let a = joints[startName],
////                    let b = joints[endName]
////                else { continue }
////
////                var path = Path()
////                path.move(to: project(a.point, in: size))
////                path.addLine(to: project(b.point, in: size))
////
////                context.stroke(
////                    path,
////                    with: .color(boneColor.opacity(0.85)),
////                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
////                )
////            }
////
////            // Draw joint dots
////            for joint in joints.values {
////                let center  = project(joint.point, in: size)
////                let dotSize: CGFloat = headJoints.contains(joint.name) ? 9 : 7
////
////                let rect = CGRect(
////                    x: center.x - dotSize / 2,
////                    y: center.y - dotSize / 2,
////                    width: dotSize,
////                    height: dotSize
////                )
////
////                context.fill(Path(ellipseIn: rect), with: .color(.white))
////                context.stroke(
////                    Path(ellipseIn: rect),
////                    with: .color(boneColor),
////                    lineWidth: 1.5
////                )
////            }
////        }
////    }
////
////    // Vision coords: Y already flipped in ViewModel (1 - y).
////    // Front camera is mirrored → flip X so skeleton matches the preview.
//////    private func project(_ point: CGPoint, in size: CGSize) -> CGPoint {
//////        CGPoint(
//////            x: (1.0 - point.x) * size.width,
//////            y: point.y          * size.height
//////        )
//////    }
////    // ✅ Only flip Y — Vision's origin is bottom-left, screen is top-left
////    // X is already correct because we used .leftMirrored orientation
////    private func project(_ point: CGPoint, in size: CGSize) -> CGPoint {
////        CGPoint(
////            x: point.x          * size.width,
////            y: (1.0 - point.y)  * size.height   // flip Y only
////        )
////    }
////
////    private let headJoints: Set<String> = [
////        "nose", "right_eye", "left_eye", "right_ear", "left_ear"
////    ]
////}
////
////// MARK: - Camera Feed (UIViewRepresentable)
////
////struct CameraFeedView: UIViewRepresentable {
////    let viewModel: ExerciseDetectionViewModel
////
////    func makeUIView(context: Context) -> PreviewView {
////        let view = PreviewView()
////        view.backgroundColor = .black
////        return view
////    }
////
////    func updateUIView(_ uiView: PreviewView, context: Context) {
////        if let session = viewModel.captureSession {
////            uiView.attachSession(session)
////        }
////    }
////
////    func makeCoordinator() -> Coordinator { Coordinator() }
////    class Coordinator {}
////}
////
////// UIView whose backing CALayer IS the AVCaptureVideoPreviewLayer.
////// Apple's own recommended pattern — no manual frame sync needed.
////final class PreviewView: UIView {
////
////    override class var layerClass: AnyClass {
////        AVCaptureVideoPreviewLayer.self
////    }
////
////    var previewLayer: AVCaptureVideoPreviewLayer {
////        layer as! AVCaptureVideoPreviewLayer
////    }
////
////    func attachSession(_ session: AVCaptureSession) {
////        guard previewLayer.session == nil else { return }
////        previewLayer.session      = session
////        previewLayer.videoGravity = .resizeAspectFill
////    }
////}
////
////// MARK: - Preview
////
////#Preview {
////    PostureCheckView(
////        exercise: Exercise(
////            name: "Plank",
////            targetAreas: ["Core", "Shoulders"],
////            equipments: ["Mat"],
////            executionSteps: ["Hold a straight body position on forearms and toes."],
////            tips: ["Keep hips level."],
////            assistanceAvailable: true,
////            demoVideo: nil,
////            setData: [SetData(sets: 3, reps: 45)]
////        )
////    )
////}
////
////  PostureCheckView.swift
////  Rep_Right
////
////  Created by Mayurakshi Das on 25/04/26.
////
//
//import SwiftUI
//import AVFoundation
//
//// MARK: - PostureCheckView
//
//struct PostureCheckView: View {
//    var exercise: Exercise
//    @State private var viewModel = ExerciseDetectionViewModel()
//    @Environment(\.dismiss) var dismiss
//
//    // MARK: Exercise ID mapping
//    private var exerciseId: Int {
//        switch exercise.name {
//        case "Plank":               return 1
//        case "Wall Sit":            return 2
//        case "Bodyweight Squat":    return 3
//        case "Glute Bridge Hold":   return 4
//        case "Dead Hang":           return 5
//        case "Overhead Hold":       return 6
//        case "Push-Up":             return 7
//        case "Forearm Plank":       return 8
//        case "Side Plank":          return 9
//        case "Lunge Hold":          return 10
//        case "Hip Abduction Hold":  return 11
//        case "L-Sit Hold":          return 12
//        case "Hollow Body Hold":    return 13
//        case "Superman Hold":       return 14
//        default:                    return 1
//        }
//    }
//
////    private var formPercent: Double {
////        Double(viewModel.analysisResult?.confidence ?? 0) * 100
////    }
//    // NEW: Drive the visible accuracy from the view model's live non-optional score so it updates every analyzed frame.
//    private var formPercent: Double {
//        viewModel.liveFormPercent
//    }
//
//    private var accuracyColor: Color {
//        if formPercent >= 75 { return .green }
//        if formPercent >= 40 { return .orange }
//        return .red
//    }
//
//    // MARK: Body
//    var body: some View {
//        ZStack {
//
//            // LAYER 1 — Camera feed (full screen)
////            CameraFeedView(viewModel: viewModel)
//            // NEW: Render the camera preview and 19-point overlay in the same preview-layer-backed view so points stay on the user.
//            CameraFeedView(
//                viewModel: viewModel,
//                joints: viewModel.currentPose.joints,
//                isCorrect: viewModel.analysisResult?.isCorrect
//            )
//                .ignoresSafeArea()
//
//            // LAYER 2 — Skeleton overlay (dots + bones)
////            SkeletonOverlayView(
////                joints: viewModel.currentPose.joints,
////                isCorrect: viewModel.analysisResult?.isCorrect
////            )
////            // NEW: Use a posture-specific overlay view name to avoid colliding with the older workout overlay type.
////            PostureSkeletonOverlayView(
////                joints: viewModel.currentPose.joints,
////                isCorrect: viewModel.analysisResult?.isCorrect
////            )
////            .ignoresSafeArea()
//
//            // LAYER 3 — UI controls
//            VStack(spacing: 0) {
//
//                // ── Top bar ──────────────────────────────────────────────
//                HStack {
//                    Button {
//                        viewModel.stopCameraSession()
//                        dismiss()
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.title)
//                            .foregroundStyle(.white)
//                            .shadow(color: .black.opacity(0.4), radius: 4)
//                    }
//                    .padding()
//                    .accessibilityLabel("Close posture check")
//
//                    Spacer()
//
//                    // LIVE pill — only shown when camera is running
//                    if viewModel.isAnalyzing {
//                        LivePillView()
//                            .padding()
//                    }
//                }
//                // NEW: Show placement guidance from the JSON rule so users know whether to keep the phone in portrait or landscape and where to place it.
//                CameraPlacementBanner(guidance: viewModel.currentCameraGuidance)
//                    .padding(.horizontal, 16)
//
//                Spacer()
//
//                // ── Bottom feedback card ──────────────────────────────────
//                FeedbackCardView(
//                    exercise: exercise,
//                    formPercent: formPercent,
//                    accuracyColor: accuracyColor,
//                    analysisResult: viewModel.analysisResult,
//                    cameraPermissionGranted: viewModel.cameraPermissionGranted
//                )
//                .padding(.horizontal, 16)
//                .padding(.bottom, 24)
//            }
//        }
//        .ignoresSafeArea(edges: .top)
//        .onAppear {
//            // ✅ Correct: call directly on viewModel (no $), correct method name
//            viewModel.setCurrentExercise(id: exerciseId)
//            viewModel.startCameraSession()
//        }
//        .onDisappear {
//            viewModel.stopCameraSession()
//        }
//    }
//}
//
//// MARK: - Live Pill
//
//private struct LivePillView: View {
//    @State private var pulse = false
//
//    var body: some View {
//        HStack(spacing: 5) {
//            Circle()
//                .fill(.red)
//                .frame(width: 8, height: 8)
//                .scaleEffect(pulse ? 1.3 : 1.0)
//                .animation(.easeInOut(duration: 0.7).repeatForever(), value: pulse)
//            Text("LIVE")
//                .font(.caption.bold())
//                .foregroundStyle(.white)
//        }
//        .padding(.horizontal, 10)
//        .padding(.vertical, 5)
//        .background(.black.opacity(0.5), in: Capsule())
//        .onAppear { pulse = true }
//    }
//}
//
//// MARK: - Feedback Card
//
//private struct FeedbackCardView: View {
//    let exercise: Exercise
//    let formPercent: Double
//    let accuracyColor: Color
//    let analysisResult: ExerciseAnalysisResult?
//    let cameraPermissionGranted: Bool
//
////    // NEW: Break the first active flag into an "issue" and a "fix" so correction guidance is obvious while the user holds the pose.
////    private var primaryCorrectionParts: (issue: String, fix: String?)? {
////        guard let firstFlag = analysisResult?.flags.first else { return nil }
////        let parts = firstFlag.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true)
////
////        if parts.count == 2 {
////            return (
////                issue: parts[0].trimmingCharacters(in: .whitespacesAndNewlines),
////                fix: parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
////            )
////        }
////
////        return (
////            issue: firstFlag.trimmingCharacters(in: .whitespacesAndNewlines),
////            fix: nil
////        )
////    }
//    // NEW: Parse the top feedback line into an issue/fix pair, with a fallback correction sentence when only one sentence is available.
//    private var primaryCorrectionParts: (issue: String, fix: String?)? {
//        guard let firstFlag = analysisResult?.flags.first else { return nil }
//        let normalized = firstFlag.replacingOccurrences(of: "—", with: ". ")
//        let parts = normalized.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true)
//
//        if parts.count == 2 {
//            return (
//                issue: parts[0].trimmingCharacters(in: .whitespacesAndNewlines),
//                fix: parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
//            )
//        }
//
//        return (
//            issue: normalized.trimmingCharacters(in: .whitespacesAndNewlines),
//            fix: "Adjust the highlighted joints until your body matches the target hold."
//        )
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 14) {
//
//            // Exercise name + score
//            HStack {
//                Text(exercise.name)
//                    .font(.title3.bold())
//                    .foregroundStyle(.white)
//                Spacer()
//                Text("\(Int(formPercent))%")
//                    .font(.title2.bold())
//                    .foregroundStyle(accuracyColor)
//                    .contentTransition(.numericText())
//                    .animation(.easeOut(duration: 0.3), value: formPercent)
//            }
//
//            // Progress bar
//            GeometryReader { geo in
//                ZStack(alignment: .leading) {
//                    Capsule()
//                        .fill(.white.opacity(0.2))
//                        .frame(height: 8)
//                    Capsule()
//                        .fill(accuracyColor)
//                        .frame(
//                            width: geo.size.width * min(formPercent / 100.0, 1.0),
//                            height: 8
//                        )
//                        .animation(.easeOut(duration: 0.35), value: formPercent)
//                }
//            }
//            .frame(height: 8)
//
//            // Status row
//            if let result = analysisResult {
//                HStack(spacing: 6) {
//                    Image(systemName: result.isCorrect
//                          ? "checkmark.seal.fill"
//                          : "exclamationmark.triangle.fill")
//                        .foregroundStyle(result.isCorrect ? .green : .orange)
//                    Text(result.isCorrect ? "Good Form" : "Needs Correction")
//                        .font(.subheadline.bold())
//                        .foregroundStyle(.white)
//                }
////                if let result = analysisResult {
////                    HStack(spacing: 6) {
////                        Image(systemName: result.isCorrect
////                              ? "checkmark.seal.fill"
////                              : "exclamationmark.triangle.fill")
////                            .foregroundStyle(result.isCorrect ? .green : .orange)
////                        Text(result.isCorrect ? "Good Form" : "Needs Correction")
////                            .font(.subheadline.bold())
////                            .foregroundStyle(.white)
////                    }
////                }
//                // NEW: Show the top live correction cue directly under the status so the user sees what is wrong and how to fix it immediately.
//                if let correction = primaryCorrectionParts, !result.isCorrect {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Issue: \(correction.issue)")
//                            .font(.caption.weight(.semibold))
//                            .foregroundStyle(.orange)
//                        if let fix = correction.fix, !fix.isEmpty {
//                            Text("Fix: \(fix)")
//                                .font(.caption)
//                                .foregroundStyle(.white.opacity(0.92))
//                        }
//                    }
//                }
//            } else {
//                Text("Step in front of the camera…")
//                    .font(.subheadline)
//                    .foregroundStyle(.white.opacity(0.6))
//            }
//
//            Divider()
//                .overlay(.white.opacity(0.25))
//
//            // Flags / suggestions
//            if let result = analysisResult {
//                if result.flags.isEmpty {
//                    HStack(spacing: 8) {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundStyle(.green)
//                        Text("No issues detected. Keep it up!")
//                            .font(.subheadline)
//                            .foregroundStyle(.white)
//                    }
//                } else {
//                    // Scrollable flags if there are many
//                    ScrollView(.vertical, showsIndicators: false) {
//                        VStack(alignment: .leading, spacing: 8) {
//                            ForEach(result.flags, id: \.self) { flag in
//                                HStack(alignment: .top, spacing: 8) {
//                                    Image(systemName: "exclamationmark.circle.fill")
//                                        .foregroundStyle(.orange)
//                                        .font(.subheadline)
//                                    Text(flag)
//                                        .font(.subheadline)
//                                        .foregroundStyle(.white)
//                                    Spacer()
//                                }
//                            }
//                        }
//                    }
//                    .frame(maxHeight: 120)
//                }
//            }
//
//            // Camera permission error
//            if !cameraPermissionGranted {
//                HStack(spacing: 8) {
//                    Image(systemName: "camera.fill")
//                        .foregroundStyle(.red)
//                    Text("Camera access denied. Enable it in Settings.")
//                        .font(.caption)
//                        .foregroundStyle(.red)
//                }
//            }
//        }
//        .padding(20)
//        .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 24))
//    }
//}
//
//private struct CameraPlacementBanner: View {
//    let guidance: CameraPlacementGuidance
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 10) {
//            Image(systemName: guidance.requiresLandscape ? "iphone.landscape" : "iphone")
//                .font(.title3)
//                .foregroundStyle(.white)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(guidance.title)
//                    .font(.subheadline.bold())
//                    .foregroundStyle(.white)
//                Text(guidance.message)
//                    .font(.caption)
//                    .foregroundStyle(.white.opacity(0.9))
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//
//            Spacer()
//        }
//        .padding(12)
//        .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 18))
//    }
//}
//
//// MARK: - Skeleton Overlay
//
////struct SkeletonOverlayView: View {
//// NEW: Renamed the active posture overlay view so Swift no longer resolves to the older WorkoutTab overlay type.
//struct PostureSkeletonOverlayView: View {
//    let joints: [String: BodyJoint]
//    let isCorrect: Bool?
//
//    /// Bone connections matching Vision's 19-point body pose skeleton
//    private let connections: [(String, String)] = [
//        // Head
//        ("nose", "right_eye"), ("nose", "left_eye"),
//        ("right_eye", "right_ear"), ("left_eye", "left_ear"),
//        // Neck
//        ("nose", "neck"),
//        // Shoulders
//        ("neck", "right_shoulder"), ("neck", "left_shoulder"),
//        // Right arm
//        ("right_shoulder", "right_elbow"), ("right_elbow", "right_wrist"),
//        // Left arm
//        ("left_shoulder", "left_elbow"), ("left_elbow", "left_wrist"),
//        // Torso
//        ("right_shoulder", "right_hip"), ("left_shoulder", "left_hip"),
//        ("right_hip", "left_hip"),
//        // Right leg
//        ("right_hip", "right_knee"), ("right_knee", "right_ankle"),
//        // Left leg
//        ("left_hip", "left_knee"), ("left_knee", "left_ankle")
//    ]
//
//    private var boneColor: Color {
//        guard let correct = isCorrect else { return .yellow }
//        return correct ? .green : .orange
//    }
//
//    var body: some View {
//        GeometryReader { geo in
//            Canvas { context, size in
//
//                // ── Draw bones ────────────────────────────────────────────
//                for (startName, endName) in connections {
//                    guard let startJoint = joints[startName],
//                          let endJoint   = joints[endName] else { continue }
//
//                    let startPt = denormalize(startJoint.point, in: size)
//                    let endPt   = denormalize(endJoint.point,   in: size)
//
//                    var path = Path()
//                    path.move(to: startPt)
//                    path.addLine(to: endPt)
//
//                    context.stroke(
//                        path,
//                        with: .color(boneColor.opacity(0.85)),
//                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
//                    )
//                }
//
//                // ── Draw joint dots ───────────────────────────────────────
//                for joint in joints.values {
//                    let pt      = denormalize(joint.point, in: size)
//                    let dotSize: CGFloat = isHeadJoint(joint.name) ? 9 : 7
//
//                    let rect = CGRect(
//                        x: pt.x - dotSize / 2,
//                        y: pt.y - dotSize / 2,
//                        width: dotSize,
//                        height: dotSize
//                    )
//
//                    // White fill
//                    context.fill(
//                        Path(ellipseIn: rect),
//                        with: .color(.white)
//                    )
//                    // Colored border
//                    context.stroke(
//                        Path(ellipseIn: rect),
//                        with: .color(boneColor),
//                        lineWidth: 1.5
//                    )
//                }
//            }
//            // ⬇ keep canvas from consuming touch events
//            .allowsHitTesting(false)
//        }
//    }
//
//    // MARK: Helpers
//
//    /// Convert Vision normalized (0–1, Y flipped) coords → screen points.
//    /// Vision: origin bottom-left, Y already flipped in ViewModel.
//    /// Front camera preview is mirrored → flip X here for correct alignment.
//    private func denormalize(_ point: CGPoint, in size: CGSize) -> CGPoint {
//        let flippedX = 1.0 - point.x   // mirror for front camera
//        return CGPoint(
//            x: flippedX * size.width,
//            y: point.y  * size.height
//        )
//    }
//
//    private func isHeadJoint(_ name: String) -> Bool {
//        ["nose", "right_eye", "left_eye", "right_ear", "left_ear"].contains(name)
//    }
//}
//
//// MARK: - Camera Feed Bridge
//
//struct CameraFeedView: UIViewRepresentable {
//    let viewModel: ExerciseDetectionViewModel
//    let joints: [String: BodyJoint]
//    let isCorrect: Bool?
//
//    func makeUIView(context: Context) -> PreviewView {
//        let view = PreviewView()
//        view.backgroundColor = .black
//        return view
//    }
//
//    func updateUIView(_ uiView: PreviewView, context: Context) {
//        // Called whenever @Observable viewModel publishes a change.
//        // captureSession is set on the main thread BEFORE startRunning(),
//        // so by the time this fires the session is ready to attach.
//        if let session = viewModel.captureSession {
//            uiView.attachSession(session)
//        }
//        // NEW: Keep the live preview rotation synced with the same orientation logic used by Vision.
//        uiView.updatePreviewOrientation(rotationAngle: viewModel.previewRotationAngle)
//        // NEW: Draw the skeleton directly in preview-layer coordinates so the points stay attached to the user.
//        uiView.updateSkeleton(joints: joints, isCorrect: isCorrect)
//    }
//
//    func makeCoordinator() -> Coordinator { Coordinator() }
//    class Coordinator {}
//}
//
//// UIView subclass whose backing layer IS the AVCaptureVideoPreviewLayer.
//// This is Apple's recommended pattern — no sublayer frame management needed.
//final class PreviewView: UIView {
//    private let bonesLayer = CAShapeLayer()
//    private let jointsLayer = CAShapeLayer()
//    // NEW: Keep the same 19-point skeleton connections in the preview-backed overlay layer.
//    private let connections: [(String, String)] = [
//        ("nose", "right_eye"), ("nose", "left_eye"),
//        ("right_eye", "right_ear"), ("left_eye", "left_ear"),
//        ("nose", "neck"),
//        ("neck", "right_shoulder"), ("neck", "left_shoulder"),
//        ("right_shoulder", "right_elbow"), ("right_elbow", "right_wrist"),
//        ("left_shoulder", "left_elbow"), ("left_elbow", "left_wrist"),
//        ("right_shoulder", "right_hip"), ("left_shoulder", "left_hip"),
//        ("right_hip", "left_hip"),
//        ("right_hip", "right_knee"), ("right_knee", "right_ankle"),
//        ("left_hip", "left_knee"), ("left_knee", "left_ankle")
//    ]
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configureOverlayLayers()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override class var layerClass: AnyClass {
//        AVCaptureVideoPreviewLayer.self
//    }
//
//    var previewLayer: AVCaptureVideoPreviewLayer {
//        // Safe: layerClass guarantees this cast succeeds
//        layer as! AVCaptureVideoPreviewLayer
//    }
//
//    private func configureOverlayLayers() {
//        bonesLayer.fillColor = UIColor.clear.cgColor
//        bonesLayer.lineWidth = 2.5
//        bonesLayer.lineCap = .round
//
//        jointsLayer.lineWidth = 1.5
//        jointsLayer.fillColor = UIColor.white.cgColor
//
//        layer.addSublayer(bonesLayer)
//        layer.addSublayer(jointsLayer)
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        bonesLayer.frame = bounds
//        jointsLayer.frame = bounds
//    }
//
//    func attachSession(_ session: AVCaptureSession) {
//        guard previewLayer.session == nil else { return } // idempotent
//        previewLayer.session      = session
//        previewLayer.videoGravity = .resizeAspectFill
//    }
//
//    // NEW: Apply the same rotation angle to the preview layer so the camera feed and skeleton stay aligned.
//    func updatePreviewOrientation(rotationAngle: CGFloat) {
//        guard let connection = previewLayer.connection else { return }
//        if connection.isVideoRotationAngleSupported(rotationAngle) {
//            connection.videoRotationAngle = rotationAngle
//        }
////        if connection.isVideoMirroringSupported {
////            connection.isVideoMirrored = true
////        }
//        // NEW: Disable automatic mirroring on the preview layer connection before applying manual front-camera mirroring.
//        if connection.isVideoMirroringSupported {
//            connection.automaticallyAdjustsVideoMirroring = false
//            connection.isVideoMirrored = true
//        }
//    }
//
//    // NEW: Convert normalized pose points through AVCaptureVideoPreviewLayer so the overlay follows rotation, mirroring, and aspect-fill cropping.
//    func updateSkeleton(joints: [String: BodyJoint], isCorrect: Bool?) {
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//
//        guard !joints.isEmpty else {
//            bonesLayer.path = nil
//            jointsLayer.path = nil
//            CATransaction.commit()
//            return
//        }
//
//        let strokeColor: UIColor
//        if let isCorrect {
//            strokeColor = isCorrect ? .systemGreen : .systemOrange
//        } else {
//            strokeColor = .systemYellow
//        }
//
////        let flippedX = 1.0 - point.x
////        return CGPoint(
////            x: flippedX * size.width,
////            y: point.y  * size.height
////        )
//        // NEW: Let AVCaptureVideoPreviewLayer convert capture-device points instead of manually flipping/scaling in SwiftUI space.
//        func previewPoint(for point: CGPoint) -> CGPoint {
//            previewLayer.layerPointConverted(fromCaptureDevicePoint: point)
//        }
//
//        let bonesPath = CGMutablePath()
//        let jointsPath = CGMutablePath()
//
//        for (startName, endName) in connections {
//            guard let startJoint = joints[startName],
//                  let endJoint = joints[endName] else { continue }
//
//            bonesPath.move(to: previewPoint(for: startJoint.point))
//            bonesPath.addLine(to: previewPoint(for: endJoint.point))
//        }
//
//        for joint in joints.values {
//            let point = previewPoint(for: joint.point)
//            let dotSize: CGFloat = ["nose", "right_eye", "left_eye", "right_ear", "left_ear"].contains(joint.name) ? 9 : 7
//            jointsPath.addEllipse(in: CGRect(
//                x: point.x - dotSize / 2,
//                y: point.y - dotSize / 2,
//                width: dotSize,
//                height: dotSize
//            ))
//        }
//
//        bonesLayer.strokeColor = strokeColor.withAlphaComponent(0.85).cgColor
//        bonesLayer.path = bonesPath
//
//        jointsLayer.strokeColor = strokeColor.cgColor
//        jointsLayer.path = jointsPath
//
//        CATransaction.commit()
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    PostureCheckView(
//        exercise: Exercise(
//            name: "Plank",
//            targetAreas: ["Core", "Shoulders"],
//            equipments: ["Mat"],
//            executionSteps: ["Hold a straight body position on forearms and toes."],
//            tips: ["Keep hips level."],
//            assistanceAvailable: true,
//            demoVideo: nil,
//            setData: [SetData(sets: 3, reps: 45)]
//        )
//    )
//}
