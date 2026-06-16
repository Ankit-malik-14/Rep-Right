import AVFoundation
import Vision
import SwiftUI

// MARK: - Data Models

struct BodyJoint {
    let name: String
    let point: CGPoint
    let confidence: Float
}

struct DetectedPose {
    var joints: [String: BodyJoint] = [:]
    var isValid: Bool = false
}

struct ExerciseAnalysisResult {
    let exerciseId: Int
    let exerciseName: String
    let isCorrect: Bool
    let confidence: Float
    let flags: [String]
    let jointCoordinates: [String: CGPoint]
    let jointAngles: [String: Float]
}

struct GenericAngleRule: Codable {
    let joint_a: String
    let joint_b: String
    let joint_c: String
    let min_angle: Float
    let max_angle: Float
    let error_flag: String
}

struct GenericAlignmentRule: Codable {
    let joint_a: String
    let joint_b: String
    let max_diff: Float
    let axis: String
    let error_flag: String
}

struct GenericRelativeRule: Codable {
    let joint: String
    let reference: String
    let `operator`: String
    let offset: Float
    let axis: String
    let error_flag: String
}

struct GenericRules: Codable {
    let angle_rules: [GenericAngleRule]?
    let alignment_rules: [GenericAlignmentRule]?
    let relative_rules: [GenericRelativeRule]?
}

struct RulesetRoot: Codable {
    let exercises: [ExerciseRule]
}

struct ExerciseRule: Codable {
    let id: Int
    let name: String
    let description: String
    let generic_rules: GenericRules?
    let flags: [String: String]
}

// Helper to calculate angle between 3 points
func calculateAngle(a: CGPoint, b: CGPoint, c: CGPoint) -> Float {
    let ab = CGPoint(x: a.x - b.x, y: a.y - b.y)
    let cb = CGPoint(x: c.x - b.x, y: c.y - b.y)
    
    let dot = ab.x * cb.x + ab.y * cb.y
    let cross = ab.x * cb.y - ab.y * cb.x
    
    let angle = atan2(cross, dot) * 180 / .pi
    return Float(abs(angle))
}

@Observable
class ExerciseDetectionViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var currentPose: DetectedPose = DetectedPose()
    var analysisResult: ExerciseAnalysisResult?
    var jointOverlayPoints: [CGPoint] = []
    var repCount: Int = 0
    var elapsedFormatted: String = "00:00"
    var initialElapsedSeconds: Int = 0
    var analyzedFrameCount: Int = 0
    var correctFrameCount: Int = 0
    
    var captureSession: AVCaptureSession?
    private let sessionQueue = DispatchQueue(label: "com.rep.sessionQueue")
    private let processingQueue = DispatchQueue(label: "com.rep.processingQueue")
    
    private var exerciseRules: [ExerciseRule] = []
    var currentExerciseRuleID: Int? = nil
    var currentExerciseName: String = "Plank"
    var currentExerciseRuleName: String?
    var usesStaticHoldProgress: Bool = true
    
    // EMA smoothing
    private var previousJoints: [String: CGPoint] = [:]
    private let alpha: CGFloat = 0.4 // 40% new, 60% old

    // Rep counting
    private enum RepPhase {
        case idle
        case tracking
        case refractory
    }

    private struct RepCounterState {
        var phase: RepPhase = .idle
        var peakSeen: Bool = false
        var framesInCycle: Int = 0
        var refractoryFramesRemaining: Int = 0
        var smoothedActivation: Double?
        var isArmed: Bool = false
    }

    private struct RepCountingProfile {
        let trigger: Double
        let peak: Double
        let reset: Double
        let refractoryFrames: Int
        let maxCycleFrames: Int
        let signalProvider: ([String: CGPoint]) -> Double?
    }

    private var repCounterState = RepCounterState()
    private var feedbackCounts: [String: Int] = [:]
    
    // Elapsed set timer
    var elapsedSeconds: Int = 0
    private var elapsedTimer: Timer?
    private var holdProgressTimer: Timer?
    
    // Camera toggle for front/back
    private var cameraPosition: AVCaptureDevice.Position = .front
    
    override init() {
        super.init()
        loadExerciseRules()
    }
    
    func toggleCamera() {
        // Reconfigure session with opposite camera
        captureSession?.stopRunning()
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition == .front ? .back : .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        captureSession?.addInput(input)
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: processingQueue)
        if captureSession?.canAddOutput(output) == true {
            captureSession?.addOutput(output)
        }
        if let connection = output.connection(with: .video) {
            connection.videoRotationAngle = 90
            connection.isVideoMirrored = (cameraPosition == .front)
        }
        cameraPosition = cameraPosition == .front ? .back : .front
        captureSession?.startRunning()
    }
    
    func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
        holdProgressTimer?.invalidate()
        holdProgressTimer = nil
    }
    
    func startElapsedTimer() {
        elapsedSeconds = initialElapsedSeconds
        elapsedFormatted = Self.formatElapsedTime(initialElapsedSeconds)
        elapsedTimer?.invalidate()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.elapsedSeconds += 1
                self.elapsedFormatted = Self.formatElapsedTime(self.elapsedSeconds)
            }
        }
    }
    
    func startSetTracking() {
        repCount = 0
        elapsedSeconds = initialElapsedSeconds
        elapsedFormatted = Self.formatElapsedTime(initialElapsedSeconds)
        analyzedFrameCount = 0
        correctFrameCount = 0
        feedbackCounts = [:]
        repCounterState = RepCounterState()
        startElapsedTimer()
        if usesStaticHoldProgress {
            startHoldProgressTimer()
        }
    }

    func finishSetTracking() {
        stopElapsedTimer()
        repCounterState = RepCounterState()
    }
    
    var formAccuracyScore: Double? {
        guard analyzedFrameCount > 0 else { return nil }
        return (Double(correctFrameCount) / Double(analyzedFrameCount)) * 100.0
    }
    
    var topFormInsights: [String] {
        feedbackCounts
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key < rhs.key
                }
                return lhs.value > rhs.value
            }
            .prefix(3)
            .map { Self.descriptiveInsight(for: $0.key) }
    }
    
    func configureExercise(name: String, preferredRuleID: Int?, preferredRuleName: String?, usesStaticHoldProgress: Bool) {
        currentExerciseName = name
        currentExerciseRuleID = preferredRuleID
        currentExerciseRuleName = preferredRuleName
        self.usesStaticHoldProgress = usesStaticHoldProgress
    }

    private func loadExerciseRules() {
        guard let url = Bundle.main.url(forResource: "ExerciseRuleset", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(RulesetRoot.self, from: data) {
            self.exerciseRules = decoded.exercises
            print("Loaded generic rules successfully!")
        } else {
            print("Failed to decode ExerciseRuleset.json")
        }
    }
    
    private func startHoldProgressTimer() {
        holdProgressTimer?.invalidate()
        holdProgressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard self.usesStaticHoldProgress,
                      self.analysisResult?.isCorrect == true else { return }
                self.repCount += 1
            }
        }
    }
    
    func startCameraSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            let session = AVCaptureSession()
            session.sessionPreset = .high
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else { return }
            
            session.addInput(input)
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: self.processingQueue)
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            if let connection = output.connection(with: .video) {
                connection.videoRotationAngle = 90
                connection.isVideoMirrored = true // Keep mirrored
            }
            
            self.captureSession = session
            session.startRunning()
        }
    }
    
    func stopCameraSession() {
        stopElapsedTimer()
        captureSession?.stopRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
        
        guard let observation = request.results?.first else { return }
        processPose(observation)
    }
    
    private func processPose(_ observation: VNHumanBodyPoseObservation) {
        var detected = DetectedPose()
        
        let allJoints: [VNHumanBodyPoseObservation.JointName] = [
            .nose, .neck, .rightShoulder, .leftShoulder, .rightElbow, .leftElbow,
            .rightWrist, .leftWrist, .rightHip, .leftHip, .rightKnee, .leftKnee,
            .rightAnkle, .leftAnkle
        ]
        
        var rawJoints: [String: BodyJoint] = [:]
        
        for visionJoint in allJoints {
            if let pt = try? observation.recognizedPoint(visionJoint), pt.confidence > 0.3 {
                // Manually convert visionJoint enum to snake_case string since rawValue is not always friendly
                var name = ""
                switch visionJoint {
                case .nose: name = "nose"
                case .neck: name = "neck"
                case .rightShoulder: name = "right_shoulder"
                case .leftShoulder: name = "left_shoulder"
                case .rightElbow: name = "right_elbow"
                case .leftElbow: name = "left_elbow"
                case .rightWrist: name = "right_wrist"
                case .leftWrist: name = "left_wrist"
                case .rightHip: name = "right_hip"
                case .leftHip: name = "left_hip"
                case .rightKnee: name = "right_knee"
                case .leftKnee: name = "left_knee"
                case .rightAnkle: name = "right_ankle"
                case .leftAnkle: name = "left_ankle"
                default: break
                }
                
                if name.isEmpty { continue }
                
                // Flip Y for UIKit
                var newPt = CGPoint(x: pt.location.x, y: 1.0 - pt.location.y)
                
                // EMA Smoothing
                if let prev = previousJoints[name] {
                    newPt = CGPoint(x: newPt.x * alpha + prev.x * (1 - alpha),
                                    y: newPt.y * alpha + prev.y * (1 - alpha))
                }
                previousJoints[name] = newPt
                
                rawJoints[name] = BodyJoint(name: name, point: newPt, confidence: Float(pt.confidence))
            }
        }
        
        detected.joints = rawJoints
        detected.isValid = !rawJoints.isEmpty
        
        // --- Side Agnostic Parsing ---
        let rightScore = (rawJoints["right_shoulder"]?.confidence ?? 0) + (rawJoints["right_hip"]?.confidence ?? 0)
        let leftScore = (rawJoints["left_shoulder"]?.confidence ?? 0) + (rawJoints["left_hip"]?.confidence ?? 0)
        let prefix = rightScore >= leftScore ? "right_" : "left_"
        
        var mappedJoints: [String: CGPoint] = [:]
        for (key, joint) in rawJoints {
            mappedJoints[key] = joint.point
            if key.hasPrefix(prefix) {
                let baseName = key.replacingOccurrences(of: prefix, with: "")
                mappedJoints[baseName] = joint.point
            }
        }
        
        DispatchQueue.main.async {
            self.currentPose = detected
            self.jointOverlayPoints = Array(rawJoints.values.map { $0.point })
            if !self.usesStaticHoldProgress {
                self.updateRepCount(using: mappedJoints)
            }
            self.evaluateRules(mappedJoints: mappedJoints)
        }
    }
    
    private func updateRepCount(using mappedJoints: [String: CGPoint]) {
        guard let profile = repCountingProfile(for: currentExerciseName),
              let rawActivation = profile.signalProvider(mappedJoints) else {
            return
        }
        
        let activation: Double
        if let previous = repCounterState.smoothedActivation {
            activation = previous * 0.65 + rawActivation * 0.35
        } else {
            activation = rawActivation
        }
        repCounterState.smoothedActivation = activation
        
        switch repCounterState.phase {
        case .idle:
            repCounterState.framesInCycle = 0
            if activation <= profile.reset {
                repCounterState.isArmed = true
            }
            repCounterState.peakSeen = activation >= profile.peak
            if repCounterState.isArmed, activation >= profile.trigger {
                repCounterState.phase = .tracking
                repCounterState.framesInCycle = 1
            }
            
        case .tracking:
            repCounterState.framesInCycle += 1
            if activation >= profile.peak {
                repCounterState.peakSeen = true
            }
            
            if repCounterState.peakSeen, activation <= profile.reset {
                repCount += 1
                repCounterState.phase = .refractory
                repCounterState.refractoryFramesRemaining = profile.refractoryFrames
                repCounterState.peakSeen = false
                repCounterState.isArmed = false
                repCounterState.framesInCycle = 0
            } else if repCounterState.framesInCycle >= profile.maxCycleFrames {
                repCounterState.phase = .idle
                repCounterState.peakSeen = false
                repCounterState.framesInCycle = 0
            }
            
        case .refractory:
            repCounterState.refractoryFramesRemaining -= 1
            if repCounterState.refractoryFramesRemaining <= 0 {
                repCounterState.phase = .idle
                repCounterState.framesInCycle = 0
            }
        }
    }

    private func repCountingProfile(for exerciseName: String) -> RepCountingProfile? {
        let name = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        switch name {
        case "push-up":
            return RepCountingProfile(
                trigger: 0.18,
                peak: 0.48,
                reset: 0.22,
                refractoryFrames: 10,
                maxCycleFrames: 90,
                signalProvider: { [weak self] joints in
                    self?.pushUpActivation(using: joints)
                }
            )
        case "crunches", "leg raise":
            return RepCountingProfile(
                trigger: 0.16,
                peak: 0.44,
                reset: 0.20,
                refractoryFrames: 8,
                maxCycleFrames: 80,
                signalProvider: { [weak self] joints in
                    self?.coreRaiseActivation(using: joints)
                }
            )
        case "jumping jacks":
            return RepCountingProfile(
                trigger: 0.20,
                peak: 0.55,
                reset: 0.24,
                refractoryFrames: 6,
                maxCycleFrames: 70,
                signalProvider: { [weak self] joints in
                    self?.jumpingJackActivation(using: joints)
                }
            )
        default:
            return RepCountingProfile(
                trigger: 0.20,
                peak: 0.45,
                reset: 0.24,
                refractoryFrames: 8,
                maxCycleFrames: 90,
                signalProvider: { [weak self] joints in
                    self?.genericRepActivation(using: joints)
                }
            )
        }
    }

    private func pushUpActivation(using joints: [String: CGPoint]) -> Double? {
        let leftElbow = flexionActivation(
            shoulder: point(named: "left_shoulder", in: joints),
            elbow: point(named: "left_elbow", in: joints),
            wrist: point(named: "left_wrist", in: joints)
        )
        let rightElbow = flexionActivation(
            shoulder: point(named: "right_shoulder", in: joints),
            elbow: point(named: "right_elbow", in: joints),
            wrist: point(named: "right_wrist", in: joints)
        )
        
        let elbowActivation = averageOf(leftElbow, rightElbow)
        let torsoActivation = torsoCompressionActivation(using: joints)
        
        switch (elbowActivation, torsoActivation) {
        case let (lhs?, rhs?):
            return min(1.0, lhs * 0.75 + rhs * 0.25)
        case let (lhs?, nil):
            return lhs
        case let (nil, rhs?):
            return rhs
        default:
            return nil
        }
    }

    private func coreRaiseActivation(using joints: [String: CGPoint]) -> Double? {
        let shoulderHipKneeLeft = flexionActivation(
            shoulder: point(named: "left_shoulder", in: joints),
            hip: point(named: "left_hip", in: joints),
            knee: point(named: "left_knee", in: joints)
        )
        let shoulderHipKneeRight = flexionActivation(
            shoulder: point(named: "right_shoulder", in: joints),
            hip: point(named: "right_hip", in: joints),
            knee: point(named: "right_knee", in: joints)
        )
        let hipFlexion = averageOf(shoulderHipKneeLeft, shoulderHipKneeRight)
        let torsoCompression = torsoCompressionActivation(using: joints)
        
        switch (hipFlexion, torsoCompression) {
        case let (lhs?, rhs?):
            return min(1.0, lhs * 0.8 + rhs * 0.2)
        case let (lhs?, nil):
            return lhs
        case let (nil, rhs?):
            return rhs
        default:
            return nil
        }
    }

    private func jumpingJackActivation(using joints: [String: CGPoint]) -> Double? {
        let armSpread = spreadActivation(
            a: point(named: "left_wrist", in: joints),
            b: point(named: "right_wrist", in: joints),
            referenceA: point(named: "left_shoulder", in: joints),
            referenceB: point(named: "right_shoulder", in: joints),
            scale: 0.9
        )
        
        let legSpread = spreadActivation(
            a: point(named: "left_ankle", in: joints),
            b: point(named: "right_ankle", in: joints),
            referenceA: point(named: "left_hip", in: joints),
            referenceB: point(named: "right_hip", in: joints),
            scale: 1.0
        )
        
        switch (armSpread, legSpread) {
        case let (lhs?, rhs?):
            return min(1.0, lhs * 0.5 + rhs * 0.5)
        case let (lhs?, nil):
            return lhs
        case let (nil, rhs?):
            return rhs
        default:
            return nil
        }
    }

    private func genericRepActivation(using joints: [String: CGPoint]) -> Double? {
        let candidates: [Double?] = [
            flexionActivation(
                shoulder: point(named: "left_shoulder", in: joints),
                elbow: point(named: "left_elbow", in: joints),
                wrist: point(named: "left_wrist", in: joints)
            ),
            flexionActivation(
                shoulder: point(named: "right_shoulder", in: joints),
                elbow: point(named: "right_elbow", in: joints),
                wrist: point(named: "right_wrist", in: joints)
            ),
            flexionActivation(
                shoulder: point(named: "left_shoulder", in: joints),
                hip: point(named: "left_hip", in: joints),
                knee: point(named: "left_knee", in: joints)
            ),
            flexionActivation(
                shoulder: point(named: "right_shoulder", in: joints),
                hip: point(named: "right_hip", in: joints),
                knee: point(named: "right_knee", in: joints)
            ),
            flexionActivation(
                hip: point(named: "left_hip", in: joints),
                knee: point(named: "left_knee", in: joints),
                ankle: point(named: "left_ankle", in: joints)
            ),
            flexionActivation(
                hip: point(named: "right_hip", in: joints),
                knee: point(named: "right_knee", in: joints),
                ankle: point(named: "right_ankle", in: joints)
            )
        ]
        
        let available = candidates.compactMap { $0 }
        guard !available.isEmpty else { return nil }
        return available.reduce(0, +) / Double(available.count)
    }

    private func torsoCompressionActivation(using joints: [String: CGPoint]) -> Double? {
        let left = flexionActivation(
            shoulder: point(named: "left_shoulder", in: joints),
            hip: point(named: "left_hip", in: joints),
            knee: point(named: "left_knee", in: joints)
        )
        let right = flexionActivation(
            shoulder: point(named: "right_shoulder", in: joints),
            hip: point(named: "right_hip", in: joints),
            knee: point(named: "right_knee", in: joints)
        )
        return averageOf(left, right)
    }

    private func flexionActivation(
        shoulder: CGPoint?,
        elbow: CGPoint?,
        wrist: CGPoint?
    ) -> Double? {
        guard let shoulder, let elbow, let wrist else { return nil }
        return Self.normalizedFlexion(from: calculateAngle(a: shoulder, b: elbow, c: wrist))
    }

    private func flexionActivation(
        shoulder: CGPoint?,
        hip: CGPoint?,
        knee: CGPoint?
    ) -> Double? {
        guard let shoulder, let hip, let knee else { return nil }
        return Self.normalizedFlexion(from: calculateAngle(a: shoulder, b: hip, c: knee))
    }

    private func flexionActivation(
        hip: CGPoint?,
        knee: CGPoint?,
        ankle: CGPoint?
    ) -> Double? {
        guard let hip, let knee, let ankle else { return nil }
        return Self.normalizedFlexion(from: calculateAngle(a: hip, b: knee, c: ankle))
    }

    private func spreadActivation(
        a: CGPoint?,
        b: CGPoint?,
        referenceA: CGPoint?,
        referenceB: CGPoint?,
        scale: Double
    ) -> Double? {
        guard let a, let b, let referenceA, let referenceB else { return nil }
        let spread = hypot(Double(a.x - b.x), Double(a.y - b.y))
        let reference = hypot(Double(referenceA.x - referenceB.x), Double(referenceA.y - referenceB.y))
        guard reference > 0 else { return nil }
        return Self.normalizedDistanceRatio(distance: spread, reference: reference, scale: scale)
    }

    private func point(named name: String, in joints: [String: CGPoint]) -> CGPoint? {
        if let point = joints[name] {
            return point
        }
        if !name.hasPrefix("left_") {
            if let point = joints["left_\(name)"] {
                return point
            }
        }
        if !name.hasPrefix("right_") {
            if let point = joints["right_\(name)"] {
                return point
            }
        }
        return nil
    }

    private func averageOf(_ values: Double?...) -> Double? {
        let filtered = values.compactMap { $0 }
        guard !filtered.isEmpty else { return nil }
        return filtered.reduce(0, +) / Double(filtered.count)
    }

    private static func normalizedFlexion(from angle: Float) -> Double {
        let value = (180.0 - Double(angle)) / 90.0
        return min(max(value, 0), 1)
    }

    private static func normalizedDistanceRatio(distance: Double, reference: Double, scale: Double) -> Double {
        let ratio = distance / reference
        let value = (ratio - 1.0) / max(scale, 0.001)
        return min(max(value, 0), 1)
    }

    private static func formatElapsedTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private static func descriptiveInsight(for feedback: String) -> String {
        let normalized = feedback.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = normalized.lowercased()
        
        if lowercased.contains("lower your hips") {
            return "Your hips stayed a little too high during this movement. Try to lower them slightly and keep your core engaged so your body stays in a stronger, more supported line."
        }
        
        if lowercased.contains("raise your hips") {
            return "Your hips were dropping below the ideal position on repeated reps. Lift them a touch and brace through your midsection so the movement stays controlled and stable."
        }
        
        if lowercased.contains("back not straight") || lowercased.contains("rounded") {
            return "Your back position became inconsistent during the set. Focus on keeping your ribcage stacked over your pelvis and move a bit slower so your posture stays cleaner."
        }
        
        if lowercased.contains("missing joints") {
            return "Tracking became less reliable for part of the set, which usually means your body moved partially out of frame. A cleaner side angle and full-body visibility will improve the coaching feedback."
        }
        
        return "This issue showed up repeatedly in the set: \(normalized). On the next attempt, reduce the tempo slightly and prioritize correcting that position before trying to speed the reps up."
    }
    
    private func evaluateRules(mappedJoints: [String: CGPoint]) {
        guard let exercise = selectedExerciseRule() else {
            let result = ExerciseAnalysisResult(
                exerciseId: -1,
                exerciseName: currentExerciseName,
                isCorrect: false,
                confidence: 0,
                flags: ["No matching assistance rule"],
                jointCoordinates: mappedJoints,
                jointAngles: [:]
            )
            self.analysisResult = result
            analyzedFrameCount += 1
            return
        }
        
        var errorFlags: [String] = []
        var computedAngles: [String: Float] = [:]
        
        if let rules = exercise.generic_rules {
            let evaluation = evaluateGenericRules(rules, exercise: exercise, mappedJoints: mappedJoints)
            errorFlags = evaluation.flags
            computedAngles = evaluation.angles
        } else {
            let evaluation = evaluateCustomRules(for: exercise, mappedJoints: mappedJoints)
            errorFlags = evaluation.flags
            computedAngles = evaluation.angles
        }
        
        let result = ExerciseAnalysisResult(
            exerciseId: exercise.id,
            exerciseName: currentExerciseName,
            isCorrect: errorFlags.isEmpty,
            confidence: max(0, 1.0 - Float(errorFlags.count) * 0.15),
            flags: errorFlags,
            jointCoordinates: mappedJoints,
            jointAngles: computedAngles
        )
        self.analysisResult = result
        analyzedFrameCount += 1
        if errorFlags.isEmpty {
            correctFrameCount += 1
        } else {
            for flag in Set(errorFlags) {
                feedbackCounts[flag, default: 0] += 1
            }
        }
    }
    
    private func selectedExerciseRule() -> ExerciseRule? {
        if let currentExerciseRuleID,
           let exact = exerciseRules.first(where: { $0.id == currentExerciseRuleID }) {
            return exact
        }
        
        if let currentExerciseRuleName,
           let exact = exerciseRules.first(where: { $0.name.caseInsensitiveCompare(currentExerciseRuleName) == .orderedSame }) {
            return exact
        }
        
        if let exact = exerciseRules.first(where: {
            $0.name.caseInsensitiveCompare(currentExerciseName) == .orderedSame
        }) {
            return exact
        }
        
        return nil
    }
    
    private func evaluateGenericRules(
        _ rules: GenericRules,
        exercise: ExerciseRule,
        mappedJoints: [String: CGPoint]
    ) -> (flags: [String], angles: [String: Float]) {
        var errorFlags: [String] = []
        var computedAngles: [String: Float] = [:]
        
        for rule in rules.angle_rules ?? [] {
            if let a = mappedJoints[rule.joint_a],
               let b = mappedJoints[rule.joint_b],
               let c = mappedJoints[rule.joint_c] {
                let angle = calculateAngle(a: a, b: b, c: c)
                computedAngles["\(rule.joint_b)_angle"] = angle
                if angle < rule.min_angle || angle > rule.max_angle {
                    errorFlags.append(exercise.flags[rule.error_flag] ?? rule.error_flag)
                }
            } else {
                errorFlags.append("Missing joints for angle check")
            }
        }
        
        for rule in rules.alignment_rules ?? [] {
            if let a = mappedJoints[rule.joint_a],
               let b = mappedJoints[rule.joint_b] {
                let diff = rule.axis == "x" ? abs(a.x - b.x) : abs(a.y - b.y)
                if diff > CGFloat(rule.max_diff) {
                    errorFlags.append(exercise.flags[rule.error_flag] ?? rule.error_flag)
                }
            }
        }
        
        for rule in rules.relative_rules ?? [] {
            if let joint = mappedJoints[rule.joint],
               let ref = mappedJoints[rule.reference] {
                let val1 = rule.axis == "x" ? joint.x : joint.y
                let val2 = rule.axis == "x" ? ref.x : ref.y
                let target = val2 + CGFloat(rule.offset)
                
                var failed = false
                switch rule.operator {
                case "<": failed = !(val1 < target)
                case ">": failed = !(val1 > target)
                case "<=": failed = !(val1 <= target)
                case ">=": failed = !(val1 >= target)
                default: break
                }
                
                if failed {
                    errorFlags.append(exercise.flags[rule.error_flag] ?? rule.error_flag)
                }
            }
        }
        
        return (errorFlags, computedAngles)
    }
    
    private func evaluateCustomRules(
        for exercise: ExerciseRule,
        mappedJoints: [String: CGPoint]
    ) -> (flags: [String], angles: [String: Float]) {
        var flags: [String] = []
        var angles: [String: Float] = [:]
        
        func appendFlag(_ key: String) {
            flags.append(exercise.flags[key] ?? key)
        }
        
        func angle(_ a: String, _ b: String, _ c: String, store key: String) -> Float? {
            guard let pointA = mappedJoints[a],
                  let pointB = mappedJoints[b],
                  let pointC = mappedJoints[c] else { return nil }
            let computed = calculateAngle(a: pointA, b: pointB, c: pointC)
            angles[key] = computed
            return computed
        }
        
        switch exercise.name {
        case "Dead Hang":
            if let elbowAngle = angle("shoulder", "elbow", "wrist", store: "elbow_angle"), elbowAngle < 150 {
                appendFlag("elbows_bent")
            }
            if let wrist = mappedJoints["wrist"], let shoulder = mappedJoints["shoulder"], wrist.y > shoulder.y {
                appendFlag("wrists_below_shoulders")
            }
        case "Overhead Hold":
            if let elbowAngle = angle("shoulder", "elbow", "wrist", store: "elbow_angle"), elbowAngle < 150 {
                appendFlag("elbows_bent")
            }
            if let wrist = mappedJoints["wrist"], let shoulder = mappedJoints["shoulder"], wrist.y > shoulder.y - 0.15 {
                appendFlag("wrists_forward")
            }
        case "Push-Up", "High Plank (Push-up Hold)":
            if let torsoAngle = angle("shoulder", "hip", "knee", store: "hip_angle") {
                if !(170.0...190.0).contains(torsoAngle) {
                    appendFlag("body_misaligned")
                }
            } else {
                appendFlag("missing_hip_angle")
            }
        case "Low Plank (Forearm Plank)":
            if let torsoAngle = angle("shoulder", "hip", "knee", store: "hip_angle"), torsoAngle < 155 {
                appendFlag("body_misaligned")
            }
            if let elbowAngle = angle("shoulder", "elbow", "wrist", store: "elbow_angle"),
               !(70.0...110.0).contains(elbowAngle) {
                appendFlag("elbows_not_90")
            }
        case "Side Plank":
            if let shoulder = mappedJoints["shoulder"],
               let hip = mappedJoints["hip"],
               let ankle = mappedJoints["ankle"] {
                if abs(shoulder.x - hip.x) > 0.12 || abs(hip.x - ankle.x) > 0.12 {
                    appendFlag("not_straight_line")
                }
                if hip.y > max(shoulder.y, ankle.y) + 0.05 {
                    appendFlag("hip_sagging")
                }
            }
        case "Lunge Hold":
            if let kneeAngle = angle("hip", "knee", "ankle", store: "knee_angle"),
               !(80.0...105.0).contains(kneeAngle) {
                appendFlag("front_knee_angle_incorrect")
            }
            if let shoulder = mappedJoints["shoulder"], let hip = mappedJoints["hip"], abs(shoulder.x - hip.x) > 0.14 {
                appendFlag("torso_tilted")
            }
        case "Standing Hip Abduction Hold":
            if let hip = mappedJoints["hip"], let ankle = mappedJoints["ankle"], abs(ankle.x - hip.x) < 0.08 {
                appendFlag("leg_not_raised_enough")
            }
        case "L-Sit Hold":
            if let hipAngle = angle("shoulder", "hip", "knee", store: "hip_angle"),
               !(70.0...110.0).contains(hipAngle) {
                appendFlag("hip_angle_incorrect")
            }
            if let kneeAngle = angle("hip", "knee", "ankle", store: "knee_angle"), kneeAngle < 150 {
                appendFlag("legs_sagging")
            }
        case "Hollow Body Hold":
            if let hip = mappedJoints["hip"], let ankle = mappedJoints["ankle"], ankle.y > hip.y + 0.05 {
                appendFlag("legs_not_raised")
            }
            if let shoulder = mappedJoints["shoulder"], let hip = mappedJoints["hip"], shoulder.y > hip.y - 0.02 {
                appendFlag("arms_not_overhead")
            }
        case "Superman Hold":
            if let wrist = mappedJoints["wrist"], let hip = mappedJoints["hip"], wrist.y > hip.y {
                appendFlag("arms_not_elevated")
            }
            if let ankle = mappedJoints["ankle"], let hip = mappedJoints["hip"], ankle.y > hip.y {
                appendFlag("legs_not_elevated")
            }
        default:
            if let torsoAngle = angle("shoulder", "hip", "knee", store: "hip_angle"), torsoAngle < 150 {
                appendFlag("back_not_straight")
            }
        }
        
        return (Array(Set(flags)), angles)
    }
}
