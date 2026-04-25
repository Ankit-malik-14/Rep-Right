import AVFoundation
import Vision
import Combine
import UIKit

// MARK: - Data Models

/// Represents a single body joint with its position and confidence
struct BodyJoint {
    let name: String
    let point: CGPoint  // Normalized coordinates (0-1 range)
    let confidence: Float
    let visionJointName: VNHumanBodyPoseObservation.JointName
}

/// Represents detected pose with all 19 joints
struct DetectedPose {
    var joints: [String: BodyJoint] = [:]
    var timestamp: Date = Date()
    var isValid: Bool = false
}

/// Represents analysis result for an exercise
struct ExerciseAnalysisResult {
    let exerciseId: Int
    let exerciseName: String
    let isCorrect: Bool
    let confidence: Float
    let flags: [String]  // Error messages/warnings
    let jointCoordinates: [String: CGPoint]
    let jointAngles: [String: Float]  // Angles in degrees
    let timestamp: Date = Date()
}

/// Exercise rule definition loaded from JSON
struct ExerciseRule: Codable {
    let id: Int
    let name: String
    let description: String
    let camera_angle: String
    let target_angle_range: AnyCodable
    let primary_joints: [String]
    let rules: [String: AnyCodable]
    let expected_accuracy: Double
    let flags: [String: String]
}

/// Helper for decoding mixed-type JSON values
enum AnyCodable: Codable {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case array([AnyCodable])
    case object([String: AnyCodable])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) { self = .int(intVal) }
        else if let dblVal = try? container.decode(Double.self) { self = .double(dblVal) }
        else if let strVal = try? container.decode(String.self) { self = .string(strVal) }
        else if let boolVal = try? container.decode(Bool.self) { self = .bool(boolVal) }
        else if let arrVal = try? container.decode([AnyCodable].self) { self = .array(arrVal) }
        else if let objVal = try? container.decode([String: AnyCodable].self) { self = .object(objVal) }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode AnyCodable") }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let val): try container.encode(val)
        case .double(let val): try container.encode(val)
        case .string(let val): try container.encode(val)
        case .bool(let val): try container.encode(val)
        case .array(let val): try container.encode(val)
        case .object(let val): try container.encode(val)
        }
    }
}

// MARK: - Main ViewModel

class ExerciseDetectionViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: Published Properties (for SwiftUI binding)
    
    @Published var currentPose: DetectedPose = DetectedPose()
    @Published var analysisResult: ExerciseAnalysisResult?
    @Published var jointOverlayPoints: [CGPoint] = []
    @Published var cameraPermissionGranted = false
    @Published var isAnalyzing = false
    @Published var errorMessages: [String] = []
    
    // MARK: Private Properties
    
    private var captureSession: AVCaptureSession?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private let sessionQueue = DispatchQueue(label: "com.rep.sessionQueue")
    private let processingQueue = DispatchQueue(label: "com.rep.processingQueue")
    
    private var exerciseRules: [ExerciseRule] = []
    private var currentExerciseId: Int = 1
    private let poseRequest = VNDetectHumanBodyPoseRequest()
    
    // Joint mapping for Vision framework
    private let jointMapping: [String: VNHumanBodyPoseObservation.JointName] = [
        "nose": .nose,
        "neck": .neck,
        "right_shoulder": .rightShoulder,
        "right_elbow": .rightElbow,
        "right_wrist": .rightWrist,
        "left_shoulder": .leftShoulder,
        "left_elbow": .leftElbow,
        "left_wrist": .leftWrist,
        "right_hip": .rightHip,
        "right_knee": .rightKnee,
        "right_ankle": .rightAnkle,
        "left_hip": .leftHip,
        "left_knee": .leftKnee,
        "left_ankle": .leftAnkle,
        "right_eye": .rightEye,
        "left_eye": .leftEye,
        "right_ear": .rightEar,
        "left_ear": .leftEar
    ]
    
    // MARK: Initialization
    
    override init() {
        super.init()
        loadExerciseRules()
        checkCameraPermission()
    }
    
    // MARK: Camera Permission & Setup
    
    /// Check and request camera permission
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermissionGranted = granted
                }
            }
        case .denied, .restricted:
            cameraPermissionGranted = false
        @unknown default:
            break
        }
    }
    
    /// Initialize and start camera session
    func startCameraSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = .high
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                print("❌ Failed to get front camera device")
                return
            }
            
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                print("❌ Failed to create video device input")
                return
            }
            
            guard captureSession.canAddInput(videoDeviceInput) else {
                print("❌ Cannot add video device input to session")
                return
            }
            
            captureSession.addInput(videoDeviceInput)
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: self.processingQueue)
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            
            guard captureSession.canAddOutput(videoDataOutput) else {
                print("❌ Cannot add video data output to session")
                return
            }
            
            captureSession.addOutput(videoDataOutput)
            
            // Set video orientation
            if let connection = videoDataOutput.connection(with: .video) {
                connection.videoOrientation = .portrait
            }
            
            self.captureSession = captureSession
            self.videoDataOutput = videoDataOutput
            
            DispatchQueue.main.async {
                captureSession.startRunning()
                print("✅ Camera session started successfully")
            }
        }
    }
    
    /// Stop camera session
    func stopCameraSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            print("✅ Camera session stopped")
        }
    }
    
    // MARK: - Exercise Rules Loading
    
    /// Load exercise rules from JSON bundle
    private func loadExerciseRules() {
        guard let jsonURL = Bundle.main.url(forResource: "ExerciseRuleset", withExtension: "json") else {
            print("❌ ExerciseRuleset.json not found in bundle")
            errorMessages.append("Failed to load exercise rules")
            return
        }
        
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            let decoder = JSONDecoder()
            let rulesetData = try decoder.decode([String: [ExerciseRule]].self, from: jsonData)
            exerciseRules = rulesetData["exercises"] ?? []
            print("✅ Loaded \(exerciseRules.count) exercise rules")
        } catch {
            print("❌ Error loading exercise rules: \(error)")
            errorMessages.append("Failed to parse exercise rules: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Set Current Exercise
    
    /// Set which exercise to analyze (1-14)
    func setCurrentExercise(id: Int) {
        guard id > 0 && id <= 14 else {
            print("❌ Invalid exercise ID: \(id). Must be 1-14")
            return
        }
        currentExerciseId = id
        errorMessages.removeAll()
        analysisResult = nil
        print("📋 Current exercise set to: \(exerciseRules[id - 1].name)")
    }
    
    // MARK: - Pose Detection (called per frame)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        
        do {
            try requestHandler.perform([poseRequest])
            
            guard let observation = poseRequest.results?.first as? VNHumanBodyPoseObservation else {
                return
            }
            
            processingQueue.async { [weak self] in
                self?.processPose(observation)
            }
        } catch {
            print("⚠️ Pose detection error: \(error)")
        }
    }
    
    /// Process detected pose and extract joints
    private func processPose(_ observation: VNHumanBodyPoseObservation) {
        var detectedPose = DetectedPose()
        detectedPose.isValid = true
        
        // Extract all available joints
        for (jointName, visionJointName) in jointMapping {
            do {
                let recognizedPoint = try observation.recognizedPoint(visionJointName)
                
                // Filter by confidence threshold (0.5 = 50%)
                guard recognizedPoint.confidence > 0.5 else { continue }
                
                let bodyJoint = BodyJoint(
                    name: jointName,
                    point: CGPoint(x: recognizedPoint.location.x, y: recognizedPoint.location.y),
                    confidence: Float(recognizedPoint.confidence),
                    visionJointName: visionJointName
                )
                
                detectedPose.joints[jointName] = bodyJoint
            } catch {
                continue
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.currentPose = detectedPose
            
            // Extract overlay points for rendering (normalized to screen coordinates)
            self?.jointOverlayPoints = detectedPose.joints.values.map { joint in
                CGPoint(x: joint.point.x, y: joint.point.y)
            }
        }
        
        // Automatically analyze if set
        analyzeCurrentPose()
    }
    
    // MARK: - Exercise Analysis
    
    /// Analyze current pose against selected exercise rules
    func analyzeCurrentPose() {
        guard currentPose.isValid, !currentPose.joints.isEmpty else { return }
        
        let exercise = exerciseRules[currentExerciseId - 1]
        var flags: [String] = []
        var jointAngles: [String: Float] = [:]
        
        // Extract joint coordinates
        let jointCoordinates = currentPose.joints.mapValues { $0.point }
        
        // MARK: Validation Logic Per Exercise
        
        switch currentExerciseId {
        
        case 1: // Plank
            flags = validatePlank(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculatePlankAngles(joints: currentPose.joints)
            
        case 2: // Wall Sit
            flags = validateWallSit(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateKneeAngles(joints: currentPose.joints)
            
        case 3: // Static Squat Hold
            flags = validateStaticSquat(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateKneeAngles(joints: currentPose.joints)
            
        case 4: // Glute Bridge Hold
            flags = validateGlueBridge(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateHipAngles(joints: currentPose.joints)
            
        case 5: // Dead Hang
            flags = validateDeadHang(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateArmAngles(joints: currentPose.joints)
            
        case 6: // Overhead Hold
            flags = validateOverheadHold(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateArmAngles(joints: currentPose.joints)
            
        case 7: // High Plank
            flags = validateHighPlank(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculatePlankAngles(joints: currentPose.joints)
            
        case 8: // Low Plank
            flags = validateLowPlank(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateForearmPlankAngles(joints: currentPose.joints)
            
        case 9: // Side Plank
            flags = validateSidePlank(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculatePlankAngles(joints: currentPose.joints)
            
        case 10: // Lunge Hold
            flags = validateLungeHold(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateLungeAngles(joints: currentPose.joints)
            
        case 11: // Hip Abduction
            flags = validateHipAbduction(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateHipAbductionAngles(joints: currentPose.joints)
            
        case 12: // L-Sit
            flags = validateLSit(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateHipAngles(joints: currentPose.joints)
            
        case 13: // Hollow Body
            flags = validateHollowBody(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateHollowBodyAngles(joints: currentPose.joints)
            
        case 14: // Superman
            flags = validateSuperman(exercise: exercise, joints: currentPose.joints)
            jointAngles = calculateSupermanAngles(joints: currentPose.joints)
            
        default:
            flags.append("Unknown exercise ID")
        }
        
        let isCorrect = flags.isEmpty
        let confidence = Float(1.0 - (Double(flags.count) * 0.15))  // Reduce confidence per flag
        
        let result = ExerciseAnalysisResult(
            exerciseId: currentExerciseId,
            exerciseName: exercise.name,
            isCorrect: isCorrect,
            confidence: max(0, confidence),
            flags: flags,
            jointCoordinates: jointCoordinates,
            jointAngles: jointAngles
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.analysisResult = result
            
            // Print results (no UI view, just console logs)
            self?.printAnalysisResult(result)
        }
    }
    
    // MARK: - Validation Functions (Per Exercise)
    
    private func validatePlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let shoulder = joints["right_shoulder"],
              let hip = joints["right_hip"],
              let ankle = joints["right_ankle"] else {
            flags.append("Cannot detect shoulders, hips, or ankles")
            return flags
        }
        
        // Check body alignment (should be nearly horizontal)
        let bodyAlignment = abs(shoulder.point.y - hip.point.y)
        if bodyAlignment > 0.15 {
            flags.append(exercise.flags["misaligned_body"] ?? "Body not straight")
        }
        
        if hip.point.y > shoulder.point.y + 0.1 {
            flags.append(exercise.flags["sagging_hips"] ?? "Hips sagging")
        }
        
        if let leftShoulder = joints["left_shoulder"], let leftHip = joints["left_hip"] {
            // Check bilateral symmetry
            let leftAlignment = abs(leftShoulder.point.y - leftHip.point.y)
            if leftAlignment > 0.15 {
                flags.append("Left side alignment incorrect")
            }
        }
        
        return flags
    }
    
    private func validateWallSit(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightKnee = joints["right_knee"],
              let rightAnkle = joints["right_ankle"],
              let rightHip = joints["right_hip"] else {
            flags.append("Cannot detect hip, knee, or ankle")
            return flags
        }
        
        // Calculate knee angle
        if let leftKnee = joints["left_knee"], let leftAnkle = joints["left_ankle"], let leftHip = joints["left_hip"] {
            let rightAngle = calculateAngle(a: rightHip.point, b: rightKnee.point, c: rightAnkle.point)
            let leftAngle = calculateAngle(a: leftHip.point, b: leftKnee.point, c: leftAnkle.point)
            let avgAngle = (rightAngle + leftAngle) / 2
            
            if avgAngle < 80 || avgAngle > 100 {
                flags.append(exercise.flags["knee_angle_incorrect"] ?? "Knee angle out of range")
            }
        }
        
        // Check if back is vertical (hip X should be close to shoulder X)
        if let shoulder = joints["right_shoulder"] {
            let lateralDeviation = abs(shoulder.point.x - rightHip.point.x)
            if lateralDeviation > 0.1 {
                flags.append(exercise.flags["back_tilted"] ?? "Back not vertical")
            }
        }
        
        return flags
    }
    
    private func validateStaticSquat(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightKnee = joints["right_knee"],
              let rightHip = joints["right_hip"],
              let rightAnkle = joints["right_ankle"] else {
            flags.append("Cannot detect hip, knee, or ankle")
            return flags
        }
        
        // Check knee angle (should be 80-100 degrees)
        if let leftKnee = joints["left_knee"], let leftAnkle = joints["left_ankle"], let leftHip = joints["left_hip"] {
            let rightAngle = calculateAngle(a: rightHip.point, b: rightKnee.point, c: rightAnkle.point)
            let leftAngle = calculateAngle(a: leftHip.point, b: leftKnee.point, c: leftAnkle.point)
            
            if rightAngle < 75 || rightAngle > 105 {
                flags.append(exercise.flags["knee_angle_incorrect"] ?? "Knee angle out of range")
            }
            if leftAngle < 75 || leftAngle > 105 {
                flags.append("Left knee angle incorrect")
            }
        }
        
        // Check hip position (should be below knee level)
        if rightHip.point.y < rightKnee.point.y - 0.05 {
            flags.append(exercise.flags["hips_too_high"] ?? "Hips too high")
        }
        
        return flags
    }
    
    private func validateGlueBridge(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightHip = joints["right_hip"],
              let rightKnee = joints["right_knee"],
              let rightShoulder = joints["right_shoulder"] else {
            flags.append("Cannot detect required joints")
            return flags
        }
        
        // Hip should be elevated (Y coordinate should be less than knee Y in image coordinates)
        if rightHip.point.y >= rightKnee.point.y - 0.05 {
            flags.append(exercise.flags["hips_not_elevated"] ?? "Hips not elevated")
        }
        
        // Check if shoulder-hip-knee angle is > 160 degrees
        if let leftHip = joints["left_hip"], let leftKnee = joints["left_knee"], let leftShoulder = joints["left_shoulder"] {
            let rightAngle = calculateAngle(a: rightShoulder.point, b: rightHip.point, c: rightKnee.point)
            let leftAngle = calculateAngle(a: leftShoulder.point, b: leftHip.point, c: leftKnee.point)
            
            if rightAngle < 150 {
                flags.append("Right side angle too small")
            }
            if leftAngle < 150 {
                flags.append("Left side angle too small")
            }
        }
        
        return flags
    }
    
    private func validateDeadHang(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightWrist = joints["right_wrist"],
              let rightElbow = joints["right_elbow"],
              let rightShoulder = joints["right_shoulder"],
              let leftWrist = joints["left_wrist"],
              let leftElbow = joints["left_elbow"],
              let leftShoulder = joints["left_shoulder"] else {
            flags.append("Cannot detect arms")
            return flags
        }
        
        // Check if arms are extended (angle > 160 degrees)
        let rightArmAngle = calculateAngle(a: rightWrist.point, b: rightElbow.point, c: rightShoulder.point)
        let leftArmAngle = calculateAngle(a: leftWrist.point, b: leftElbow.point, c: leftShoulder.point)
        
        if rightArmAngle < 155 {
            flags.append(exercise.flags["elbows_bent"] ?? "Right elbow bent")
        }
        if leftArmAngle < 155 {
            flags.append(exercise.flags["elbows_bent"] ?? "Left elbow bent")
        }
        
        // Check if wrists are above shoulders
        if rightWrist.point.y > rightShoulder.point.y {
            flags.append(exercise.flags["wrists_below_shoulders"] ?? "Wrists not above shoulders")
        }
        
        return flags
    }
    
    private func validateOverheadHold(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightWrist = joints["right_wrist"],
              let rightElbow = joints["right_elbow"],
              let rightShoulder = joints["right_shoulder"],
              let leftWrist = joints["left_wrist"],
              let leftElbow = joints["left_elbow"],
              let leftShoulder = joints["left_shoulder"] else {
            flags.append("Cannot detect arms")
            return flags
        }
        
        let rightArmAngle = calculateAngle(a: rightWrist.point, b: rightElbow.point, c: rightShoulder.point)
        let leftArmAngle = calculateAngle(a: leftWrist.point, b: leftElbow.point, c: leftShoulder.point)
        
        if rightArmAngle < 155 || leftArmAngle < 155 {
            flags.append(exercise.flags["elbows_bent"] ?? "Arms not straight overhead")
        }
        
        // Wrists should be above head (if detectable)
        if let nose = joints["nose"] {
            if rightWrist.point.y > nose.point.y + 0.05 {
                flags.append(exercise.flags["wrists_forward"] ?? "Arms not directly overhead")
            }
        }
        
        return flags
    }
    
    private func validateHighPlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightShoulder = joints["right_shoulder"],
              let rightHip = joints["right_hip"],
              let rightAnkle = joints["right_ankle"],
              let rightWrist = joints["right_wrist"],
              let rightElbow = joints["right_elbow"] else {
            flags.append("Cannot detect required joints")
            return flags
        }
        
        // Check body alignment
        let bodyAlignment = abs(rightShoulder.point.y - rightHip.point.y)
        if bodyAlignment > 0.15 {
            flags.append(exercise.flags["body_misaligned"] ?? "Body not straight")
        }
        
        // Check arm extension
        let armAngle = calculateAngle(a: rightWrist.point, b: rightElbow.point, c: rightShoulder.point)
        if armAngle < 155 {
            flags.append(exercise.flags["elbows_bent"] ?? "Elbows not locked")
        }
        
        // Shoulders should be over wrists
        if abs(rightShoulder.point.x - rightWrist.point.x) > 0.08 {
            flags.append(exercise.flags["shoulders_over_wrists"] ?? "Shoulders not over wrists")
        }
        
        return flags
    }
    
    private func validateLowPlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightShoulder = joints["right_shoulder"],
              let rightElbow = joints["right_elbow"],
              let rightHip = joints["right_hip"],
              let rightAnkle = joints["right_ankle"] else {
            flags.append("Cannot detect required joints")
            return flags
        }
        
        // Check body alignment
        let bodyAlignment = abs(rightShoulder.point.y - rightHip.point.y)
        if bodyAlignment > 0.15 {
            flags.append(exercise.flags["body_misaligned"] ?? "Body not straight")
        }
        
        // Check elbow angle (should be around 90 degrees)
        if let rightWrist = joints["right_wrist"] {
            let elbowAngle = calculateAngle(a: rightWrist.point, b: rightElbow.point, c: rightShoulder.point)
            if elbowAngle < 80 || elbowAngle > 100 {
                flags.append(exercise.flags["elbows_not_90"] ?? "Elbow angle incorrect")
            }
        }
        
        // Shoulder should be over elbow
        if abs(rightShoulder.point.x - rightElbow.point.x) > 0.08 {
            flags.append(exercise.flags["shoulder_not_stacked"] ?? "Shoulder not over elbow")
        }
        
        return flags
    }
    
    private func validateSidePlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightShoulder = joints["right_shoulder"],
              let rightHip = joints["right_hip"],
              let rightAnkle = joints["right_ankle"] else {
            flags.append("Cannot detect required joints")
            return flags
        }
        
        // Check vertical alignment (x coordinates should be similar)
        let lateralDeviation = abs(rightShoulder.point.x - rightHip.point.x) + abs(rightHip.point.x - rightAnkle.point.x)
        if lateralDeviation > 0.15 {
            flags.append(exercise.flags["not_straight_line"] ?? "Body not in straight line")
        }
        
        // Check hip sag (hip should not drop below shoulder-ankle line)
        let shoulderY = rightShoulder.point.y
        let ankleY = rightAnkle.point.y
        let expectedHipY = (shoulderY + ankleY) / 2
        
        if rightHip.point.y > expectedHipY + 0.1 {
            flags.append(exercise.flags["hip_sagging"] ?? "Hip sagging")
        }
        
        return flags
    }
    
    private func validateLungeHold(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightKnee = joints["right_knee"],
              let rightHip = joints["right_hip"],
              let rightAnkle = joints["right_ankle"],
              let leftKnee = joints["left_knee"],
              let leftHip = joints["left_hip"],
              let leftAnkle = joints["left_ankle"] else {
            flags.append("Cannot detect leg joints")
            return flags
        }
        
        // Check front knee angle (assume right is front)
        let frontAngle = calculateAngle(a: rightHip.point, b: rightKnee.point, c: rightAnkle.point)
        if frontAngle < 80 || frontAngle > 100 {
            flags.append(exercise.flags["front_knee_angle_incorrect"] ?? "Front knee angle out of range")
        }
        
        // Check back knee proximity to ground (left knee Y should be larger)
        if leftKnee.point.y < 0.8 {
            flags.append(exercise.flags["back_knee_too_high"] ?? "Back knee not low enough")
        }
        
        // Check torso upright
        if let rightShoulder = joints["right_shoulder"] {
            let torsoAngle = abs(rightShoulder.point.x - rightHip.point.x)
            if torsoAngle > 0.12 {
                flags.append(exercise.flags["torso_tilted"] ?? "Torso tilted forward")
            }
        }
        
        return flags
    }
    
    private func validateHipAbduction(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightHip = joints["right_hip"],
              let leftHip = joints["left_hip"],
              let rightKnee = joints["right_knee"] else {
            flags.append("Cannot detect hip/knee")
            return flags
        }
        
        // Check lateral leg separation (X coordinate difference)
        let legSeparation = abs(rightKnee.point.x - rightHip.point.x)
        if legSeparation < 0.15 {
            flags.append(exercise.flags["leg_not_raised_enough"] ?? "Leg not raised enough")
        }
        
        // Check if standing leg is straight
        if let leftKnee = joints["left_knee"], let leftAnkle = joints["left_ankle"] {
            let standingLegAngle = calculateAngle(a: leftHip.point, b: leftKnee.point, c: leftAnkle.point)
            if standingLegAngle < 160 {
                flags.append(exercise.flags["standing_leg_bent"] ?? "Standing leg bent")
            }
        }
        
        return flags
    }
    
    private func validateLSit(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightHip = joints["right_hip"],
              let rightKnee = joints["right_knee"],
              let rightAnkle = joints["right_ankle"] else {
            flags.append("Cannot detect leg joints")
            return flags
        }
        
        // Check hip angle (should be ~90 degrees)
        if let rightWrist = joints["right_wrist"], let rightShoulder = joints["right_shoulder"] {
            let hipAngle = calculateAngle(a: rightWrist.point, b: rightHip.point, c: rightKnee.point)
            if hipAngle < 80 || hipAngle > 100 {
                flags.append(exercise.flags["hip_angle_incorrect"] ?? "Hip angle not at 90°")
            }
        }
        
        // Check legs parallel to ground (Y coordinates should be similar)
        if let leftKnee = joints["left_knee"] {
            let yDifference = abs(rightKnee.point.y - leftKnee.point.y)
            if yDifference > 0.08 {
                flags.append(exercise.flags["legs_sagging"] ?? "Legs not parallel to ground")
            }
        }
        
        return flags
    }
    
    private func validateHollowBody(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightShoulder = joints["right_shoulder"],
              let rightHip = joints["right_hip"],
              let rightKnee = joints["right_knee"],
              let rightAnkle = joints["right_ankle"] else {
            flags.append("Cannot detect body joints")
            return flags
        }
        
        // Check lower back flatness (shoulder-hip-knee should be nearly straight)
        let backAngle = calculateAngle(a: rightShoulder.point, b: rightHip.point, c: rightKnee.point)
        if abs(backAngle - 180) > 15 {
            flags.append(exercise.flags["lower_back_arched"] ?? "Lower back arching")
        }
        
        // Check legs raised (ankle Y should be less than hip Y, meaning elevated)
        if rightAnkle.point.y > rightHip.point.y + 0.05 {
            flags.append(exercise.flags["legs_not_raised"] ?? "Legs not raised enough")
        }
        
        return flags
    }
    
    private func validateSuperman(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        
        guard let rightShoulder = joints["right_shoulder"],
              let rightWrist = joints["right_wrist"],
              let rightHip = joints["right_hip"],
              let rightAnkle = joints["right_ankle"] else {
            flags.append("Cannot detect body joints")
            return flags
        }
        
        // Check arms elevated (wrist Y should be less than hip Y)
        if rightWrist.point.y > rightHip.point.y - 0.05 {
            flags.append(exercise.flags["arms_not_elevated"] ?? "Arms not elevated")
        }
        
        // Check legs elevated (ankle Y should be less than hip Y)
        if rightAnkle.point.y > rightHip.point.y - 0.05 {
            flags.append(exercise.flags["legs_not_elevated"] ?? "Legs not elevated")
        }
        
        // Check chest lifted (shoulder should be elevated)
        if rightShoulder.point.y > 0.4 {
            flags.append(exercise.flags["chest_not_lifted"] ?? "Chest not lifted")
        }
        
        return flags
    }
    
    // MARK: - Angle Calculation Helper
    
    /// Calculate angle between three points (in degrees)
    private func calculateAngle(a: CGPoint, b: CGPoint, c: CGPoint) -> Float {
        let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let cb = CGPoint(x: b.x - c.x, y: b.y - c.y)
        
        let dot = ab.x * cb.x + ab.y * cb.y
        let abMag = sqrt(ab.x * ab.x + ab.y * ab.y)
        let cbMag = sqrt(cb.x * cb.x + cb.y * cb.y)
        
        guard abMag > 0, cbMag > 0 else { return 0 }
        
        let cosAngle = dot / (abMag * cbMag)
        let angle = acos(min(max(cosAngle, -1), 1)) * 180 / .pi
        
        return Float(angle)
    }
    
    // MARK: - Angle Extraction Functions (per exercise type)
    
    private func calculatePlankAngles(joints: [String: BodyJoint]) -> [String: Float] {
        var angles: [String: Float] = [:]
        
        if let shoulder = joints["right_shoulder"],
           let hip = joints["right_hip"],
           let ankle = joints["right_ankle"] {
            let bodyAngle = calculateAngle(a: shoulder.point, b: hip.point, c: ankle.point)
            angles["body_alignment"] = bodyAngle
        }
        
        return angles
    }
    
    private func calculateKneeAngles(joints: [String: BodyJoint]) -> [String: Float] {
        var angles: [String: Float] = [:]
        
        if let rightHip = joints["right_hip"],
           let rightKnee = joints["right_knee"],
           let rightAnkle = joints["right_ankle"] {
            let rightAngle = calculateAngle(a: rightHip.point, b: rightKnee.point, c: rightAnkle.point)
            angles["right_knee_angle"] = rightAngle
        }
        
        if let leftHip = joints["left_hip"],
           let leftKnee = joints["left_knee"],
           let leftAnkle = joints["left_ankle"] {
            let leftAngle = calculateAngle(a: leftHip.point, b: leftKnee.point, c: leftAnkle.point)
            angles["left_knee_angle"] = leftAngle
        }
        
        return angles
    }
    
    private func calculateHipAngles(joints: [String: BodyJoint]) -> [String: Float] {
        var angles: [String: Float] = [:]
        
        if let shoulder = joints["right_shoulder"],
           let hip = joints["right_hip"],
           let knee = joints["right_knee"] {
            let hipAngle = calculateAngle(a: shoulder.point, b: hip.point, c: knee.point)
            angles["hip_angle"] = hipAngle
        }
        
        return angles
    }
    
    private func calculateArmAngles(joints: [String: BodyJoint]) -> [String: Float] {
        var angles: [String: Float] = [:]
        
        if let rightWrist = joints["right_wrist"],
           let rightElbow = joints["right_elbow"],
           let rightShoulder = joints["right_shoulder"] {
            let rightAngle = calculateAngle(a: rightWrist.point, b: rightElbow.point, c: rightShoulder.point)
            angles["right_arm_angle"] = rightAngle
        }
        
        if let leftWrist = joints["left_wrist"],
           let leftElbow = joints["left_elbow"],
           let leftShoulder = joints["left_shoulder"] {
            let leftAngle = calculateAngle(a: leftWrist.point, b: leftElbow.point, c: leftShoulder.point)
            angles["left_arm_angle"] = leftAngle
        }
        
        return angles
    }
    
    private func calculateForearmPlankAngles(joints: [String: BodyJoint]) -> [String: Float] {
        var angles: [String: Float] = [:]
        
        if let shoulder = joints["right_shoulder"],
           let elbow = joints["right_elbow"],
           let hip = joints["right_hip"] {
            let elbowAngle = calculateAngle(a: shoulder.point, b: elbow.point, c: hip.point)
            angles["elbow_angle"] = elbowAngle
        }
        
        if let shoulder = joints["right_shoulder"],
           let hip = joints["right_hip"],
           let ankle = joints["right_ankle"] {
            let bodyAngle = calculateAngle(a: shoulder.point, b: hip.point, c: ankle.point)
            angles["body_alignment"] = bodyAngle
        }
        
        return angles
    }
    
    private func calculateLungeAngles(joints: [String: BodyJoint]) -> [String: Float] {
        var angles: [String: Float] = [:]
        
        if let rightHip = joints["right_hip"],
           let rightKnee = joints["right_knee"],
           let rightAnkle = joints["right_ankle"] {
            let rightAngle = calculateAngle(a: rightHip.point, b: rightKnee.point, c: rightAnkle.point)
            angles["front_knee_angle"] = rightAngle
        }
        
        return angles
    }
    
    private func calculateHipAbductionAngles(joints: [String: BodyJoint]) -> [String: Float] {
        var angles: [String: Float] = [:]
        
        if let hip = joints["right_hip"],
           let knee = joints["right_knee"] {
            let separation = knee.point.x - hip.point.x
            angles["leg_separation"] = Float(separation)
        }
        
        return angles
    }
    
    private func calculateHollowBodyAngles(joints: [String: BodyJoint]) -> [String: Float] {
        var angles: [String: Float] = [:]
        
        if let shoulder = joints["right_shoulder"],
           let hip = joints["right_hip"],
           let knee = joints["right_knee"] {
            let backAngle = calculateAngle(a: shoulder.point, b: hip.point, c: knee.point)
            angles["back_angle"] = backAngle
        }
        
        return angles
    }
    
    private func calculateSupermanAngles(joints: [String: BodyJoint]) -> [String: Float] {
        var angles: [String: Float] = [:]
        
        if let hip = joints["right_hip"],
           let wrist = joints["right_wrist"],
           let ankle = joints["right_ankle"] {
            let armElevation = hip.point.y - wrist.point.y
            let legElevation = hip.point.y - ankle.point.y
            angles["arm_elevation"] = Float(armElevation)
            angles["leg_elevation"] = Float(legElevation)
        }
        
        return angles
    }
    
    // MARK: - Result Printing (Console Output Only)
    
    private func printAnalysisResult(_ result: ExerciseAnalysisResult) {
        print("\n" + String(repeating: "=", count: 60))
        print("📊 EXERCISE ANALYSIS RESULT")
        print(String(repeating: "=", count: 60))
        print("Exercise: \(result.exerciseName) (ID: \(result.exerciseId))")
        print("Timestamp: \(result.timestamp)")
        print("Status: \(result.isCorrect ? "✅ CORRECT" : "❌ INCORRECT")")
        print("Confidence: \(String(format: "%.1f%%", result.confidence * 100))")
        
        if !result.flags.isEmpty {
            print("\n⚠️ Detected Issues:")
            for (index, flag) in result.flags.enumerated() {
                print("  \(index + 1). \(flag)")
            }
        } else {
            print("\n✅ No issues detected! Form looks good.")
        }
        
        print("\n📍 Joint Coordinates:")
        for (name, point) in result.jointCoordinates.sorted(by: { $0.key < $1.key }) {
            print("  \(name): (\(String(format: "%.2f", point.x)), \(String(format: "%.2f", point.y)))")
        }
        
        if !result.jointAngles.isEmpty {
            print("\n📐 Calculated Angles:")
            for (name, angle) in result.jointAngles.sorted(by: { $0.key < $1.key }) {
                print("  \(name): \(String(format: "%.1f°", angle))")
            }
        }
        
        print(String(repeating: "=", count: 60) + "\n")
    }
    
    deinit {
        stopCameraSession()
    }
}
