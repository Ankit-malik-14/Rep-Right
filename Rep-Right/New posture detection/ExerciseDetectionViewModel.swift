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
    var currentExerciseId: Int = 1
    
    // EMA smoothing
    private var previousJoints: [String: CGPoint] = [:]
    private let alpha: CGFloat = 0.4 // 40% new, 60% old
    
    // Rep counting
    private var baselineY: CGFloat? = nil
    private var peakTrackedY: CGFloat? = nil
    private var isDescending: Bool = false
    private let repThreshold: CGFloat = 0.05
    private var feedbackCounts: [String: Int] = [:]
    
    // Elapsed set timer
    var elapsedSeconds: Int = 0
    private var elapsedTimer: Timer?
    
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
        baselineY = nil
        peakTrackedY = nil
        isDescending = false
        startElapsedTimer()
    }
    
    func finishSetTracking() {
        stopElapsedTimer()
        baselineY = nil
        peakTrackedY = nil
        isDescending = false
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
            self.updateRepCount(using: mappedJoints)
            self.evaluateRules(mappedJoints: mappedJoints)
        }
    }
    
    private func updateRepCount(using mappedJoints: [String: CGPoint]) {
        let hipCandidates = [mappedJoints["hip"], mappedJoints["left_hip"], mappedJoints["right_hip"]]
        let shoulderCandidates = [mappedJoints["shoulder"], mappedJoints["left_shoulder"], mappedJoints["right_shoulder"]]
        
        let trackedPoints = hipCandidates.compactMap { $0 }
        let fallbackPoints = shoulderCandidates.compactMap { $0 }
        let sourcePoints = trackedPoints.isEmpty ? fallbackPoints : trackedPoints
        
        guard !sourcePoints.isEmpty else { return }
        
        let currentY = sourcePoints.map(\.y).reduce(0, +) / CGFloat(sourcePoints.count)
        
        if baselineY == nil {
            baselineY = currentY
            peakTrackedY = currentY
            return
        }
        
        guard let baselineY else { return }
        
        if !isDescending {
            if currentY > baselineY + repThreshold {
                isDescending = true
                peakTrackedY = currentY
            } else {
                self.baselineY = baselineY * 0.9 + currentY * 0.1
            }
            return
        }
        
        peakTrackedY = max(peakTrackedY ?? currentY, currentY)
        
        if currentY <= baselineY + repThreshold * 0.35 {
            repCount += 1
            isDescending = false
            self.baselineY = currentY
            peakTrackedY = currentY
        }
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
        guard currentExerciseId > 0 && currentExerciseId <= exerciseRules.count else { return }
        let exercise = exerciseRules[currentExerciseId - 1]
        guard let rules = exercise.generic_rules else { return }
        
        var errorFlags: [String] = []
        var computedAngles: [String: Float] = [:]
        
        // Angle Rules
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
        
        // Alignment Rules
        for rule in rules.alignment_rules ?? [] {
            if let a = mappedJoints[rule.joint_a],
               let b = mappedJoints[rule.joint_b] {
                let diff = rule.axis == "x" ? abs(a.x - b.x) : abs(a.y - b.y)
                if diff > CGFloat(rule.max_diff) {
                    errorFlags.append(exercise.flags[rule.error_flag] ?? rule.error_flag)
                }
            }
        }
        
        // Relative Rules
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
        
        let result = ExerciseAnalysisResult(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
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
}
