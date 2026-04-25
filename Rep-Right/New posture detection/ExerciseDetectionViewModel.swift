//
//Created by Mayurakshi Das


//import AVFoundation
//import Vision
//import Combine
//import UIKit
//
//// MARK: - Data Models
//
///// Represents a single body joint with its position and confidence
//struct BodyJoint {
//    let name: String
//    let point: CGPoint  // Normalized coordinates (0-1 range)
//    let confidence: Float
//    let visionJointName: VNHumanBodyPoseObservation.JointName
//}
//
///// Represents detected pose with all 19 joints
//struct DetectedPose {
//    var joints: [String: BodyJoint] = [:]
//    var timestamp: Date = Date()
//    var isValid: Bool = false
//}
//
///// Represents analysis result for an exercise
//struct ExerciseAnalysisResult {
//    let exerciseId: Int
//    let exerciseName: String
//    let isCorrect: Bool
//    let confidence: Float
//    let flags: [String]  // Error messages/warnings
//    let jointCoordinates: [String: CGPoint]
//    let jointAngles: [String: Float]  // Angles in degrees
//    let timestamp: Date = Date()
//}
//
///// Exercise rule definition loaded from JSON
//struct ExerciseRule: Codable {
//    let id: Int
//    let name: String
//    let description: String
//    let camera_angle: String
//    let target_angle_range: AnyCodable
//    let primary_joints: [String]
//    let rules: [String: AnyCodable]
//    let expected_accuracy: Double
//    let flags: [String: String]
//}
//
///// Helper for decoding mixed-type JSON values
//enum AnyCodable: Codable {
//    case int(Int)
//    case double(Double)
//    case string(String)
//    case bool(Bool)
//    case array([AnyCodable])
//    case object([String: AnyCodable])
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let intVal = try? container.decode(Int.self) { self = .int(intVal) }
//        else if let dblVal = try? container.decode(Double.self) { self = .double(dblVal) }
//        else if let strVal = try? container.decode(String.self) { self = .string(strVal) }
//        else if let boolVal = try? container.decode(Bool.self) { self = .bool(boolVal) }
//        else if let arrVal = try? container.decode([AnyCodable].self) { self = .array(arrVal) }
//        else if let objVal = try? container.decode([String: AnyCodable].self) { self = .object(objVal) }
//        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode AnyCodable") }
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        switch self {
//        case .int(let val): try container.encode(val)
//        case .double(let val): try container.encode(val)
//        case .string(let val): try container.encode(val)
//        case .bool(let val): try container.encode(val)
//        case .array(let val): try container.encode(val)
//        case .object(let val): try container.encode(val)
//        }
//    }
//}
//
//// MARK: - Main ViewModel
//
//@Observable
//class ExerciseDetectionViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
//    
//    // MARK: Published Properties (for SwiftUI binding)
//    
//     var currentPose: DetectedPose = DetectedPose()
//     var analysisResult: ExerciseAnalysisResult?
//     var jointOverlayPoints: [CGPoint] = []
//     var cameraPermissionGranted = false
//     var isAnalyzing = false
//     var errorMessages: [String] = []
//    
//    // MARK: Private Properties
//    
//    /*private*/ var captureSession: AVCaptureSession?
//    private var videoDataOutput: AVCaptureVideoDataOutput?
//    private let sessionQueue = DispatchQueue(label: "com.rep.sessionQueue")
//    private let processingQueue = DispatchQueue(label: "com.rep.processingQueue")
//    
//    private var exerciseRules: [ExerciseRule] = []
//    private var currentExerciseId: Int = 1
//    private let poseRequest = VNDetectHumanBodyPoseRequest()
//    
//    // Joint mapping for Vision framework
//    private let jointMapping: [String: VNHumanBodyPoseObservation.JointName] = [
//        "nose": .nose,
//        "neck": .neck,
//        "right_shoulder": .rightShoulder,
//        "right_elbow": .rightElbow,
//        "right_wrist": .rightWrist,
//        "left_shoulder": .leftShoulder,
//        "left_elbow": .leftElbow,
//        "left_wrist": .leftWrist,
//        "right_hip": .rightHip,
//        "right_knee": .rightKnee,
//        "right_ankle": .rightAnkle,
//        "left_hip": .leftHip,
//        "left_knee": .leftKnee,
//        "left_ankle": .leftAnkle,
//        "right_eye": .rightEye,
//        "left_eye": .leftEye,
//        "right_ear": .rightEar,
//        "left_ear": .leftEar
//    ]
//    
//    // MARK: Initialization
//    
//    override init() {
//        super.init()
//        loadExerciseRules()
//        checkCameraPermission()
//    }
//    
//    // MARK: Camera Permission & Setup
//    
//    /// Check and request camera permission
//    private func checkCameraPermission() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            cameraPermissionGranted = true
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//                DispatchQueue.main.async {
//                    self?.cameraPermissionGranted = granted
//                }
//            }
//        case .denied, .restricted:
//            cameraPermissionGranted = false
//        @unknown default:
//            break
//        }
//    }
//    
//    /// Initialize and start camera session
//    // START CMAERA
//    
////    func startCameraSession() {
////        sessionQueue.async { [weak self] in
////            guard let self = self else { return }
////            
////            let captureSession = AVCaptureSession()
////            captureSession.sessionPreset = .high
////            
////            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
////                print("❌ Failed to get front camera device")
////                return
////            }
////            
////            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
////                print("❌ Failed to create video device input")
////                return
////            }
////            
////            guard captureSession.canAddInput(videoDeviceInput) else {
////                print("❌ Cannot add video device input to session")
////                return
////            }
////            
////            captureSession.addInput(videoDeviceInput)
////            
////            let videoDataOutput = AVCaptureVideoDataOutput()
////            videoDataOutput.setSampleBufferDelegate(self, queue: self.processingQueue)
////            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
////            
////            guard captureSession.canAddOutput(videoDataOutput) else {
////                print("❌ Cannot add video data output to session")
////                return
////            }
////            
////            captureSession.addOutput(videoDataOutput)
////            
////            // Set video orientation
//////            if let connection = videoDataOutput.connection(with: .video) {
//////                connection.videoOrientation = .portrait
//////            }
////            if let connection = videoDataOutput.connection(with: .video) {
////                if connection.isVideoRotationAngleSupported(90) {
////                    connection.videoRotationAngle = 90   // 90° = portrait
////                }
////            }
////            
////            self.captureSession = captureSession
////            self.videoDataOutput = videoDataOutput
////            
////            DispatchQueue.main.async {
////                captureSession.startRunning()
////                print("✅ Camera session started successfully")
////            }
////        }
////    }
//    func startCameraSession() {
//        sessionQueue.async { [weak self] in
//            guard let self = self else { return }
//
//            let captureSession = AVCaptureSession()
//            captureSession.beginConfiguration()
//            captureSession.sessionPreset = .high
//
//            // Front camera
//            guard let videoDevice = AVCaptureDevice.default(
//                .builtInWideAngleCamera, for: .video, position: .front
//            ) else {
//                print("❌ Failed to get front camera device")
//                captureSession.commitConfiguration()
//                return
//            }
//
//            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
//                  captureSession.canAddInput(videoDeviceInput) else {
//                print("❌ Failed to add video input")
//                captureSession.commitConfiguration()
//                return
//            }
//            captureSession.addInput(videoDeviceInput)
//
//            let videoDataOutput = AVCaptureVideoDataOutput()
//            videoDataOutput.setSampleBufferDelegate(self, queue: self.processingQueue)
//            videoDataOutput.videoSettings = [
//                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
//            ]
//            videoDataOutput.alwaysDiscardsLateVideoFrames = true
//
//            guard captureSession.canAddOutput(videoDataOutput) else {
//                print("❌ Failed to add video output")
//                captureSession.commitConfiguration()
//                return
//            }
//            captureSession.addOutput(videoDataOutput)
//
//            // ✅ Fix deprecated videoOrientation
//            if let connection = videoDataOutput.connection(with: .video) {
//                if connection.isVideoRotationAngleSupported(90) {
//                    connection.videoRotationAngle = 90 // portrait
//                }
//            }
//
//            captureSession.commitConfiguration()
//
//            // ✅ Save session BEFORE startRunning so CameraFeedView can attach preview layer
//            DispatchQueue.main.async {
//                self.captureSession = captureSession
//                self.videoDataOutput = videoDataOutput
//                self.isAnalyzing = true
//            }
//
//            // ✅ startRunning() on background sessionQueue — NOT main thread
//            captureSession.startRunning()
//            print("✅ Camera session started")
//        }
//    }
//    /// Stop camera session
//    func stopCameraSession() {
//        sessionQueue.async { [weak self] in
//            self?.captureSession?.stopRunning()
//            print("✅ Camera session stopped")
//        }
//    }
//    
//    // MARK: - Exercise Rules Loading
//    
//    /// Load exercise rules from JSON bundle
//    private func loadExerciseRules() {
//        guard let jsonURL = Bundle.main.url(forResource: "ExerciseRuleset", withExtension: "json") else {
//            print("❌ ExerciseRuleset.json not found in bundle")
//            errorMessages.append("Failed to load exercise rules")
//            return
//        }
//        
//        do {
//            let jsonData = try Data(contentsOf: jsonURL)
//            let decoder = JSONDecoder()
//            let rulesetData = try decoder.decode([String: [ExerciseRule]].self, from: jsonData)
//            exerciseRules = rulesetData["exercises"] ?? []
//            print("✅ Loaded \(exerciseRules.count) exercise rules")
//        } catch {
//            print("❌ Error loading exercise rules: \(error)")
//            errorMessages.append("Failed to parse exercise rules: \(error.localizedDescription)")
//        }
//    }
//    
//    // MARK: - Set Current Exercise
//    
//    /// Set which exercise to analyze (1-14)
////    func setCurrentExercise(id: Int) {
////        guard id > 0 && id <= 14 else {
////            print("❌ Invalid exercise ID: \(id). Must be 1-14")
////            return
////        }
////        currentExerciseId = id
////        errorMessages.removeAll()
////        analysisResult = nil
////        print("📋 Current exercise set to: \(exerciseRules[id - 1].name)")
////    }
//    func setCurrentExercise(id: Int) {
//        guard id > 0 && id <= 14 else {
//            print("❌ Invalid exercise ID: \(id)")
//            return
//        }
//
//        currentExerciseId = id
//        errorMessages.removeAll()
//        analysisResult = nil
//
//        // ✅ Guard BEFORE indexing — array may still be loading or empty
//        guard !exerciseRules.isEmpty, id <= exerciseRules.count else {
//            print("⚠️ Exercise rules not loaded yet for ID: \(id)")
//            return
//        }
//
//        print("📋 Current exercise set to: \(exerciseRules[id - 1].name)")
//    }
//    
//    // MARK: - Pose Detection (called per frame)
//    
////    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
////        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
////        
////        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
////        
////        do {
////            try requestHandler.perform([poseRequest])
////            
////            guard let observation = poseRequest.results?.first as? VNHumanBodyPoseObservation else {
////                return
////            }
////            
////            processingQueue.async { [weak self] in
////                self?.processPose(observation)
////            }
////        } catch {
////            print("⚠️ Pose detection error: \(error)")
////        }
////    }
//    
//    func captureOutput(_ output: AVCaptureOutput,
//                       didOutput sampleBuffer: CMSampleBuffer,
//                       from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//
//        // ✅ .leftMirrored = front camera, portrait, mirrored
//        let requestHandler = VNImageRequestHandler(
//            cvPixelBuffer: pixelBuffer,
//            orientation: .leftMirrored,
//            options: [:]
//        )
//
//        do {
//            try requestHandler.perform([poseRequest])
//            guard let observation = poseRequest.results?.first else { return }
//            processPose(observation)          // call directly, already on processingQueue
//        } catch {
//            print("⚠️ Pose detection error: \(error)")
//        }
//    }
////    /// Process detected pose and extract joints
////    private func processPose(_ observation: VNHumanBodyPoseObservation) {
////        var detectedPose = DetectedPose()
////        detectedPose.isValid = true
////        
////        // Extract all available joints
////        for (jointName, visionJointName) in jointMapping {
////            do {
////                let recognizedPoint = try observation.recognizedPoint(visionJointName)
////                
////                // Filter by confidence threshold (0.5 = 50%)
////                guard recognizedPoint.confidence > 0.5 else { continue }
////                
////                let bodyJoint = BodyJoint(
////                    name: jointName,
////                    point: CGPoint(x: recognizedPoint.location.x, y: recognizedPoint.location.y),
////                    confidence: Float(recognizedPoint.confidence),
////                    visionJointName: visionJointName
////                )
////                
////                detectedPose.joints[jointName] = bodyJoint
////            } catch {
////                continue
////            }
////        }
////        
////        DispatchQueue.main.async { [weak self] in
////            self?.currentPose = detectedPose
////            
////            // Extract overlay points for rendering (normalized to screen coordinates)
////            self?.jointOverlayPoints = detectedPose.joints.values.map { joint in
////                CGPoint(x: joint.point.x, y: joint.point.y)
////            }
////        }
////        
////        // Automatically analyze if set
////        analyzeCurrentPose()
////    }
////    
////    // MARK: - Exercise Analysis
////    
////    /// Analyze current pose against selected exercise rules
////    func analyzeCurrentPose() {
////        guard currentPose.isValid, !currentPose.joints.isEmpty else { return }
////        
////        let exercise = exerciseRules[currentExerciseId - 1]
////        var flags: [String] = []
////        var jointAngles: [String: Float] = [:]
////        
////        // Extract joint coordinates
////        let jointCoordinates = currentPose.joints.mapValues { $0.point }
////        
////        // MARK: Validation Logic Per Exercise
////        
////        switch currentExerciseId {
////        
////        case 1: // Plank
////            flags = validatePlank(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculatePlankAngles(joints: currentPose.joints)
////            
////        case 2: // Wall Sit
////            flags = validateWallSit(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateKneeAngles(joints: currentPose.joints)
////            
////        case 3: // Static Squat Hold
////            flags = validateStaticSquat(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateKneeAngles(joints: currentPose.joints)
////            
////        case 4: // Glute Bridge Hold
////            flags = validateGlueBridge(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateHipAngles(joints: currentPose.joints)
////            
////        case 5: // Dead Hang
////            flags = validateDeadHang(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateArmAngles(joints: currentPose.joints)
////            
////        case 6: // Overhead Hold
////            flags = validateOverheadHold(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateArmAngles(joints: currentPose.joints)
////            
////        case 7: // High Plank
////            flags = validateHighPlank(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculatePlankAngles(joints: currentPose.joints)
////            
////        case 8: // Low Plank
////            flags = validateLowPlank(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateForearmPlankAngles(joints: currentPose.joints)
////            
////        case 9: // Side Plank
////            flags = validateSidePlank(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculatePlankAngles(joints: currentPose.joints)
////            
////        case 10: // Lunge Hold
////            flags = validateLungeHold(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateLungeAngles(joints: currentPose.joints)
////            
////        case 11: // Hip Abduction
////            flags = validateHipAbduction(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateHipAbductionAngles(joints: currentPose.joints)
////            
////        case 12: // L-Sit
////            flags = validateLSit(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateHipAngles(joints: currentPose.joints)
////            
////        case 13: // Hollow Body
////            flags = validateHollowBody(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateHollowBodyAngles(joints: currentPose.joints)
////            
////        case 14: // Superman
////            flags = validateSuperman(exercise: exercise, joints: currentPose.joints)
////            jointAngles = calculateSupermanAngles(joints: currentPose.joints)
////            
////        default:
////            flags.append("Unknown exercise ID")
////        }
////        
////        let isCorrect = flags.isEmpty
////        let confidence = Float(1.0 - (Double(flags.count) * 0.15))  // Reduce confidence per flag
////        
////        let result = ExerciseAnalysisResult(
////            exerciseId: currentExerciseId,
////            exerciseName: exercise.name,
////            isCorrect: isCorrect,
////            confidence: max(0, confidence),
////            flags: flags,
////            jointCoordinates: jointCoordinates,
////            jointAngles: jointAngles
////        )
////        
////        DispatchQueue.main.async { [weak self] in
////            self?.analysisResult = result
////            
////            // Print results (no UI view, just console logs)
////            self?.printAnalysisResult(result)
////        }
////    }
//    
////    private func processPose(_ observation: VNHumanBodyPoseObservation) {
////        var detectedPose = DetectedPose()
////        detectedPose.isValid = true
////
////        for (jointName, visionJointName) in jointMapping {
////            guard let recognizedPoint = try? observation.recognizedPoint(visionJointName),
////                  recognizedPoint.confidence > 0.3 else { continue }
////
////            // ✅ FIX 1: Flip Y — Vision origin is bottom-left, UIKit is top-left
////            let flippedY = 1.0 - recognizedPoint.location.y
////
////            let bodyJoint = BodyJoint(
////                name: jointName,
////                point: CGPoint(x: recognizedPoint.location.x, y: flippedY),
////                confidence: Float(recognizedPoint.confidence),
////                visionJointName: visionJointName
////            )
////            detectedPose.joints[jointName] = bodyJoint
////        }
////
////        // ✅ FIX 2: Analyze BEFORE dispatching to main (joints available here)
////        let joints = detectedPose.joints
////        let coordsForResult = joints.mapValues { $0.point }
////        analyzeDetectedJoints(joints, coordinates: coordsForResult)
////
////        DispatchQueue.main.async { [weak self] in
////            self?.currentPose = detectedPose
////            self?.jointOverlayPoints = detectedPose.joints.values.map { $0.point }
////        }
////    }
//
//    private func processPose(_ observation: VNHumanBodyPoseObservation) {
//        var detectedPose = DetectedPose()
//        detectedPose.isValid = true
//
//        for (jointName, visionJointName) in jointMapping {
//            guard let recognizedPoint = try? observation.recognizedPoint(visionJointName),
//                  recognizedPoint.confidence > 0.3 else { continue }
//
//            // ✅ NO Y flip here — Vision gives correct coords with .leftMirrored
//            // ✅ NO X flip here — .leftMirrored already handles the mirror
//            let bodyJoint = BodyJoint(
//                name: jointName,
//                point: CGPoint(
//                    x: recognizedPoint.location.x,
//                    y: recognizedPoint.location.y   // raw, unflipped
//                ),
//                confidence: Float(recognizedPoint.confidence),
//                visionJointName: visionJointName
//            )
//            detectedPose.joints[jointName] = bodyJoint
//        }
//
//        let joints = detectedPose.joints
//        let coords = joints.mapValues { $0.point }
//        analyzeDetectedJoints(joints, coordinates: coords)
//
//        DispatchQueue.main.async { [weak self] in
//            self?.currentPose = detectedPose
//            self?.jointOverlayPoints = detectedPose.joints.values.map { $0.point }
//        }
//    }
//    // ✅ FIX 3: New method — takes joints directly instead of reading currentPose
//    func analyzeDetectedJoints(_ joints: [String: BodyJoint], coordinates: [String: CGPoint]) {
//        guard !joints.isEmpty else { return }
//        guard !exerciseRules.isEmpty,
//              currentExerciseId > 0,
//              currentExerciseId <= exerciseRules.count else { return }
//
//        let exercise = exerciseRules[currentExerciseId - 1]
//        var flags: [String] = []
//        var jointAngles: [String: Float] = [:]
//
//        switch currentExerciseId {
//        case 1:  flags = validatePlank(exercise: exercise, joints: joints);           jointAngles = calculatePlankAngles(joints: joints)
//        case 2:  flags = validateWallSit(exercise: exercise, joints: joints);         jointAngles = calculateKneeAngles(joints: joints)
//        case 3:  flags = validateStaticSquat(exercise: exercise, joints: joints);     jointAngles = calculateKneeAngles(joints: joints)
//        case 4:  flags = validateGlueBridge(exercise: exercise, joints: joints);      jointAngles = calculateHipAngles(joints: joints)
//        case 5:  flags = validateDeadHang(exercise: exercise, joints: joints);        jointAngles = calculateArmAngles(joints: joints)
//        case 6:  flags = validateOverheadHold(exercise: exercise, joints: joints);    jointAngles = calculateArmAngles(joints: joints)
//        case 7:  flags = validateHighPlank(exercise: exercise, joints: joints);       jointAngles = calculatePlankAngles(joints: joints)
//        case 8:  flags = validateLowPlank(exercise: exercise, joints: joints);        jointAngles = calculateForearmPlankAngles(joints: joints)
//        case 9:  flags = validateSidePlank(exercise: exercise, joints: joints);       jointAngles = calculatePlankAngles(joints: joints)
//        case 10: flags = validateLungeHold(exercise: exercise, joints: joints);       jointAngles = calculateLungeAngles(joints: joints)
//        case 11: flags = validateHipAbduction(exercise: exercise, joints: joints);    jointAngles = calculateHipAbductionAngles(joints: joints)
//        case 12: flags = validateLSit(exercise: exercise, joints: joints);            jointAngles = calculateHipAngles(joints: joints)
//        case 13: flags = validateHollowBody(exercise: exercise, joints: joints);      jointAngles = calculateHollowBodyAngles(joints: joints)
//        case 14: flags = validateSuperman(exercise: exercise, joints: joints);        jointAngles = calculateSupermanAngles(joints: joints)
//        default: flags.append("Unknown exercise ID")
//        }
//
//        let isCorrect = flags.isEmpty
//        let confidence = max(0, Float(1.0 - Double(flags.count) * 0.15))
//
//        let result = ExerciseAnalysisResult(
//            exerciseId: currentExerciseId,
//            exerciseName: exercise.name,
//            isCorrect: isCorrect,
//            confidence: confidence,
//            flags: flags,
//            jointCoordinates: coordinates,
//            jointAngles: jointAngles
//        )
//
//        DispatchQueue.main.async { [weak self] in
//            self?.analysisResult = result
//        }
//    }
//    // MARK: - Validation Functions (Per Exercise)
//    
//    private func validatePlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let shoulder = joints["right_shoulder"],
//              let hip = joints["right_hip"],
//              let ankle = joints["right_ankle"] else {
//            flags.append("Cannot detect shoulders, hips, or ankles")
//            return flags
//        }
//        
//        // Check body alignment (should be nearly horizontal)
//        let bodyAlignment = abs(shoulder.point.y - hip.point.y)
//        if bodyAlignment > 0.15 {
//            flags.append(exercise.flags["misaligned_body"] ?? "Body not straight")
//        }
//        
//        if hip.point.y > shoulder.point.y + 0.1 {
//            flags.append(exercise.flags["sagging_hips"] ?? "Hips sagging")
//        }
//        
//        if let leftShoulder = joints["left_shoulder"], let leftHip = joints["left_hip"] {
//            // Check bilateral symmetry
//            let leftAlignment = abs(leftShoulder.point.y - leftHip.point.y)
//            if leftAlignment > 0.15 {
//                flags.append("Left side alignment incorrect")
//            }
//        }
//        
//        return flags
//    }
//    
//    private func validateWallSit(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightKnee = joints["right_knee"],
//              let rightAnkle = joints["right_ankle"],
//              let rightHip = joints["right_hip"] else {
//            flags.append("Cannot detect hip, knee, or ankle")
//            return flags
//        }
//        
//        // Calculate knee angle
//        if let leftKnee = joints["left_knee"], let leftAnkle = joints["left_ankle"], let leftHip = joints["left_hip"] {
//            let rightAngle = calculateAngle(a: rightHip.point, b: rightKnee.point, c: rightAnkle.point)
//            let leftAngle = calculateAngle(a: leftHip.point, b: leftKnee.point, c: leftAnkle.point)
//            let avgAngle = (rightAngle + leftAngle) / 2
//            
//            if avgAngle < 80 || avgAngle > 100 {
//                flags.append(exercise.flags["knee_angle_incorrect"] ?? "Knee angle out of range")
//            }
//        }
//        
//        // Check if back is vertical (hip X should be close to shoulder X)
//        if let shoulder = joints["right_shoulder"] {
//            let lateralDeviation = abs(shoulder.point.x - rightHip.point.x)
//            if lateralDeviation > 0.1 {
//                flags.append(exercise.flags["back_tilted"] ?? "Back not vertical")
//            }
//        }
//        
//        return flags
//    }
//    
//    private func validateStaticSquat(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightKnee = joints["right_knee"],
//              let rightHip = joints["right_hip"],
//              let rightAnkle = joints["right_ankle"] else {
//            flags.append("Cannot detect hip, knee, or ankle")
//            return flags
//        }
//        
//        // Check knee angle (should be 80-100 degrees)
//        if let leftKnee = joints["left_knee"], let leftAnkle = joints["left_ankle"], let leftHip = joints["left_hip"] {
//            let rightAngle = calculateAngle(a: rightHip.point, b: rightKnee.point, c: rightAnkle.point)
//            let leftAngle = calculateAngle(a: leftHip.point, b: leftKnee.point, c: leftAnkle.point)
//            
//            if rightAngle < 75 || rightAngle > 105 {
//                flags.append(exercise.flags["knee_angle_incorrect"] ?? "Knee angle out of range")
//            }
//            if leftAngle < 75 || leftAngle > 105 {
//                flags.append("Left knee angle incorrect")
//            }
//        }
//        
//        // Check hip position (should be below knee level)
//        if rightHip.point.y < rightKnee.point.y - 0.05 {
//            flags.append(exercise.flags["hips_too_high"] ?? "Hips too high")
//        }
//        
//        return flags
//    }
//    
//    private func validateGlueBridge(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightHip = joints["right_hip"],
//              let rightKnee = joints["right_knee"],
//              let rightShoulder = joints["right_shoulder"] else {
//            flags.append("Cannot detect required joints")
//            return flags
//        }
//        
//        // Hip should be elevated (Y coordinate should be less than knee Y in image coordinates)
//        if rightHip.point.y >= rightKnee.point.y - 0.05 {
//            flags.append(exercise.flags["hips_not_elevated"] ?? "Hips not elevated")
//        }
//        
//        // Check if shoulder-hip-knee angle is > 160 degrees
//        if let leftHip = joints["left_hip"], let leftKnee = joints["left_knee"], let leftShoulder = joints["left_shoulder"] {
//            let rightAngle = calculateAngle(a: rightShoulder.point, b: rightHip.point, c: rightKnee.point)
//            let leftAngle = calculateAngle(a: leftShoulder.point, b: leftHip.point, c: leftKnee.point)
//            
//            if rightAngle < 150 {
//                flags.append("Right side angle too small")
//            }
//            if leftAngle < 150 {
//                flags.append("Left side angle too small")
//            }
//        }
//        
//        return flags
//    }
//    
//    private func validateDeadHang(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightWrist = joints["right_wrist"],
//              let rightElbow = joints["right_elbow"],
//              let rightShoulder = joints["right_shoulder"],
//              let leftWrist = joints["left_wrist"],
//              let leftElbow = joints["left_elbow"],
//              let leftShoulder = joints["left_shoulder"] else {
//            flags.append("Cannot detect arms")
//            return flags
//        }
//        
//        // Check if arms are extended (angle > 160 degrees)
//        let rightArmAngle = calculateAngle(a: rightWrist.point, b: rightElbow.point, c: rightShoulder.point)
//        let leftArmAngle = calculateAngle(a: leftWrist.point, b: leftElbow.point, c: leftShoulder.point)
//        
//        if rightArmAngle < 155 {
//            flags.append(exercise.flags["elbows_bent"] ?? "Right elbow bent")
//        }
//        if leftArmAngle < 155 {
//            flags.append(exercise.flags["elbows_bent"] ?? "Left elbow bent")
//        }
//        
//        // Check if wrists are above shoulders
//        if rightWrist.point.y > rightShoulder.point.y {
//            flags.append(exercise.flags["wrists_below_shoulders"] ?? "Wrists not above shoulders")
//        }
//        
//        return flags
//    }
//    
//    private func validateOverheadHold(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightWrist = joints["right_wrist"],
//              let rightElbow = joints["right_elbow"],
//              let rightShoulder = joints["right_shoulder"],
//              let leftWrist = joints["left_wrist"],
//              let leftElbow = joints["left_elbow"],
//              let leftShoulder = joints["left_shoulder"] else {
//            flags.append("Cannot detect arms")
//            return flags
//        }
//        
//        let rightArmAngle = calculateAngle(a: rightWrist.point, b: rightElbow.point, c: rightShoulder.point)
//        let leftArmAngle = calculateAngle(a: leftWrist.point, b: leftElbow.point, c: leftShoulder.point)
//        
//        if rightArmAngle < 155 || leftArmAngle < 155 {
//            flags.append(exercise.flags["elbows_bent"] ?? "Arms not straight overhead")
//        }
//        
//        // Wrists should be above head (if detectable)
//        if let nose = joints["nose"] {
//            if rightWrist.point.y > nose.point.y + 0.05 {
//                flags.append(exercise.flags["wrists_forward"] ?? "Arms not directly overhead")
//            }
//        }
//        
//        return flags
//    }
//    
//    private func validateHighPlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightShoulder = joints["right_shoulder"],
//              let rightHip = joints["right_hip"],
//              let rightAnkle = joints["right_ankle"],
//              let rightWrist = joints["right_wrist"],
//              let rightElbow = joints["right_elbow"] else {
//            flags.append("Cannot detect required joints")
//            return flags
//        }
//        
//        // Check body alignment
//        let bodyAlignment = abs(rightShoulder.point.y - rightHip.point.y)
//        if bodyAlignment > 0.15 {
//            flags.append(exercise.flags["body_misaligned"] ?? "Body not straight")
//        }
//        
//        // Check arm extension
//        let armAngle = calculateAngle(a: rightWrist.point, b: rightElbow.point, c: rightShoulder.point)
//        if armAngle < 155 {
//            flags.append(exercise.flags["elbows_bent"] ?? "Elbows not locked")
//        }
//        
//        // Shoulders should be over wrists
//        if abs(rightShoulder.point.x - rightWrist.point.x) > 0.08 {
//            flags.append(exercise.flags["shoulders_over_wrists"] ?? "Shoulders not over wrists")
//        }
//        
//        return flags
//    }
//    
//    private func validateLowPlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightShoulder = joints["right_shoulder"],
//              let rightElbow = joints["right_elbow"],
//              let rightHip = joints["right_hip"],
//              let rightAnkle = joints["right_ankle"] else {
//            flags.append("Cannot detect required joints")
//            return flags
//        }
//        
//        // Check body alignment
//        let bodyAlignment = abs(rightShoulder.point.y - rightHip.point.y)
//        if bodyAlignment > 0.15 {
//            flags.append(exercise.flags["body_misaligned"] ?? "Body not straight")
//        }
//        
//        // Check elbow angle (should be around 90 degrees)
//        if let rightWrist = joints["right_wrist"] {
//            let elbowAngle = calculateAngle(a: rightWrist.point, b: rightElbow.point, c: rightShoulder.point)
//            if elbowAngle < 80 || elbowAngle > 100 {
//                flags.append(exercise.flags["elbows_not_90"] ?? "Elbow angle incorrect")
//            }
//        }
//        
//        // Shoulder should be over elbow
//        if abs(rightShoulder.point.x - rightElbow.point.x) > 0.08 {
//            flags.append(exercise.flags["shoulder_not_stacked"] ?? "Shoulder not over elbow")
//        }
//        
//        return flags
//    }
//    
//    private func validateSidePlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightShoulder = joints["right_shoulder"],
//              let rightHip = joints["right_hip"],
//              let rightAnkle = joints["right_ankle"] else {
//            flags.append("Cannot detect required joints")
//            return flags
//        }
//        
//        // Check vertical alignment (x coordinates should be similar)
//        let lateralDeviation = abs(rightShoulder.point.x - rightHip.point.x) + abs(rightHip.point.x - rightAnkle.point.x)
//        if lateralDeviation > 0.15 {
//            flags.append(exercise.flags["not_straight_line"] ?? "Body not in straight line")
//        }
//        
//        // Check hip sag (hip should not drop below shoulder-ankle line)
//        let shoulderY = rightShoulder.point.y
//        let ankleY = rightAnkle.point.y
//        let expectedHipY = (shoulderY + ankleY) / 2
//        
//        if rightHip.point.y > expectedHipY + 0.1 {
//            flags.append(exercise.flags["hip_sagging"] ?? "Hip sagging")
//        }
//        
//        return flags
//    }
//    
//    private func validateLungeHold(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightKnee = joints["right_knee"],
//              let rightHip = joints["right_hip"],
//              let rightAnkle = joints["right_ankle"],
//              let leftKnee = joints["left_knee"],
//              let leftHip = joints["left_hip"],
//              let leftAnkle = joints["left_ankle"] else {
//            flags.append("Cannot detect leg joints")
//            return flags
//        }
//        
//        // Check front knee angle (assume right is front)
//        let frontAngle = calculateAngle(a: rightHip.point, b: rightKnee.point, c: rightAnkle.point)
//        if frontAngle < 80 || frontAngle > 100 {
//            flags.append(exercise.flags["front_knee_angle_incorrect"] ?? "Front knee angle out of range")
//        }
//        
//        // Check back knee proximity to ground (left knee Y should be larger)
//        if leftKnee.point.y < 0.8 {
//            flags.append(exercise.flags["back_knee_too_high"] ?? "Back knee not low enough")
//        }
//        
//        // Check torso upright
//        if let rightShoulder = joints["right_shoulder"] {
//            let torsoAngle = abs(rightShoulder.point.x - rightHip.point.x)
//            if torsoAngle > 0.12 {
//                flags.append(exercise.flags["torso_tilted"] ?? "Torso tilted forward")
//            }
//        }
//        
//        return flags
//    }
//    
//    private func validateHipAbduction(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightHip = joints["right_hip"],
//              let leftHip = joints["left_hip"],
//              let rightKnee = joints["right_knee"] else {
//            flags.append("Cannot detect hip/knee")
//            return flags
//        }
//        
//        // Check lateral leg separation (X coordinate difference)
//        let legSeparation = abs(rightKnee.point.x - rightHip.point.x)
//        if legSeparation < 0.15 {
//            flags.append(exercise.flags["leg_not_raised_enough"] ?? "Leg not raised enough")
//        }
//        
//        // Check if standing leg is straight
//        if let leftKnee = joints["left_knee"], let leftAnkle = joints["left_ankle"] {
//            let standingLegAngle = calculateAngle(a: leftHip.point, b: leftKnee.point, c: leftAnkle.point)
//            if standingLegAngle < 160 {
//                flags.append(exercise.flags["standing_leg_bent"] ?? "Standing leg bent")
//            }
//        }
//        
//        return flags
//    }
//    
//    private func validateLSit(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightHip = joints["right_hip"],
//              let rightKnee = joints["right_knee"],
//              let rightAnkle = joints["right_ankle"] else {
//            flags.append("Cannot detect leg joints")
//            return flags
//        }
//        
//        // Check hip angle (should be ~90 degrees)
//        if let rightWrist = joints["right_wrist"], let rightShoulder = joints["right_shoulder"] {
//            let hipAngle = calculateAngle(a: rightWrist.point, b: rightHip.point, c: rightKnee.point)
//            if hipAngle < 80 || hipAngle > 100 {
//                flags.append(exercise.flags["hip_angle_incorrect"] ?? "Hip angle not at 90°")
//            }
//        }
//        
//        // Check legs parallel to ground (Y coordinates should be similar)
//        if let leftKnee = joints["left_knee"] {
//            let yDifference = abs(rightKnee.point.y - leftKnee.point.y)
//            if yDifference > 0.08 {
//                flags.append(exercise.flags["legs_sagging"] ?? "Legs not parallel to ground")
//            }
//        }
//        
//        return flags
//    }
//    
//    private func validateHollowBody(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightShoulder = joints["right_shoulder"],
//              let rightHip = joints["right_hip"],
//              let rightKnee = joints["right_knee"],
//              let rightAnkle = joints["right_ankle"] else {
//            flags.append("Cannot detect body joints")
//            return flags
//        }
//        
//        // Check lower back flatness (shoulder-hip-knee should be nearly straight)
//        let backAngle = calculateAngle(a: rightShoulder.point, b: rightHip.point, c: rightKnee.point)
//        if abs(backAngle - 180) > 15 {
//            flags.append(exercise.flags["lower_back_arched"] ?? "Lower back arching")
//        }
//        
//        // Check legs raised (ankle Y should be less than hip Y, meaning elevated)
//        if rightAnkle.point.y > rightHip.point.y + 0.05 {
//            flags.append(exercise.flags["legs_not_raised"] ?? "Legs not raised enough")
//        }
//        
//        return flags
//    }
//    
//    private func validateSuperman(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
//        var flags: [String] = []
//        
//        guard let rightShoulder = joints["right_shoulder"],
//              let rightWrist = joints["right_wrist"],
//              let rightHip = joints["right_hip"],
//              let rightAnkle = joints["right_ankle"] else {
//            flags.append("Cannot detect body joints")
//            return flags
//        }
//        
//        // Check arms elevated (wrist Y should be less than hip Y)
//        if rightWrist.point.y > rightHip.point.y - 0.05 {
//            flags.append(exercise.flags["arms_not_elevated"] ?? "Arms not elevated")
//        }
//        
//        // Check legs elevated (ankle Y should be less than hip Y)
//        if rightAnkle.point.y > rightHip.point.y - 0.05 {
//            flags.append(exercise.flags["legs_not_elevated"] ?? "Legs not elevated")
//        }
//        
//        // Check chest lifted (shoulder should be elevated)
//        if rightShoulder.point.y > 0.4 {
//            flags.append(exercise.flags["chest_not_lifted"] ?? "Chest not lifted")
//        }
//        
//        return flags
//    }
//    
//    // MARK: - Angle Calculation Helper
//    
//    /// Calculate angle between three points (in degrees)
//    private func calculateAngle(a: CGPoint, b: CGPoint, c: CGPoint) -> Float {
//        let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
//        let cb = CGPoint(x: b.x - c.x, y: b.y - c.y)
//        
//        let dot = ab.x * cb.x + ab.y * cb.y
//        let abMag = sqrt(ab.x * ab.x + ab.y * ab.y)
//        let cbMag = sqrt(cb.x * cb.x + cb.y * cb.y)
//        
//        guard abMag > 0, cbMag > 0 else { return 0 }
//        
//        let cosAngle = dot / (abMag * cbMag)
//        let angle = acos(min(max(cosAngle, -1), 1)) * 180 / .pi
//        
//        return Float(angle)
//    }
//    
//    // MARK: - Angle Extraction Functions (per exercise type)
//    
//    private func calculatePlankAngles(joints: [String: BodyJoint]) -> [String: Float] {
//        var angles: [String: Float] = [:]
//        
//        if let shoulder = joints["right_shoulder"],
//           let hip = joints["right_hip"],
//           let ankle = joints["right_ankle"] {
//            let bodyAngle = calculateAngle(a: shoulder.point, b: hip.point, c: ankle.point)
//            angles["body_alignment"] = bodyAngle
//        }
//        
//        return angles
//    }
//    
//    private func calculateKneeAngles(joints: [String: BodyJoint]) -> [String: Float] {
//        var angles: [String: Float] = [:]
//        
//        if let rightHip = joints["right_hip"],
//           let rightKnee = joints["right_knee"],
//           let rightAnkle = joints["right_ankle"] {
//            let rightAngle = calculateAngle(a: rightHip.point, b: rightKnee.point, c: rightAnkle.point)
//            angles["right_knee_angle"] = rightAngle
//        }
//        
//        if let leftHip = joints["left_hip"],
//           let leftKnee = joints["left_knee"],
//           let leftAnkle = joints["left_ankle"] {
//            let leftAngle = calculateAngle(a: leftHip.point, b: leftKnee.point, c: leftAnkle.point)
//            angles["left_knee_angle"] = leftAngle
//        }
//        
//        return angles
//    }
//    
//    private func calculateHipAngles(joints: [String: BodyJoint]) -> [String: Float] {
//        var angles: [String: Float] = [:]
//        
//        if let shoulder = joints["right_shoulder"],
//           let hip = joints["right_hip"],
//           let knee = joints["right_knee"] {
//            let hipAngle = calculateAngle(a: shoulder.point, b: hip.point, c: knee.point)
//            angles["hip_angle"] = hipAngle
//        }
//        
//        return angles
//    }
//    
//    private func calculateArmAngles(joints: [String: BodyJoint]) -> [String: Float] {
//        var angles: [String: Float] = [:]
//        
//        if let rightWrist = joints["right_wrist"],
//           let rightElbow = joints["right_elbow"],
//           let rightShoulder = joints["right_shoulder"] {
//            let rightAngle = calculateAngle(a: rightWrist.point, b: rightElbow.point, c: rightShoulder.point)
//            angles["right_arm_angle"] = rightAngle
//        }
//        
//        if let leftWrist = joints["left_wrist"],
//           let leftElbow = joints["left_elbow"],
//           let leftShoulder = joints["left_shoulder"] {
//            let leftAngle = calculateAngle(a: leftWrist.point, b: leftElbow.point, c: leftShoulder.point)
//            angles["left_arm_angle"] = leftAngle
//        }
//        
//        return angles
//    }
//    
//    private func calculateForearmPlankAngles(joints: [String: BodyJoint]) -> [String: Float] {
//        var angles: [String: Float] = [:]
//        
//        if let shoulder = joints["right_shoulder"],
//           let elbow = joints["right_elbow"],
//           let hip = joints["right_hip"] {
//            let elbowAngle = calculateAngle(a: shoulder.point, b: elbow.point, c: hip.point)
//            angles["elbow_angle"] = elbowAngle
//        }
//        
//        if let shoulder = joints["right_shoulder"],
//           let hip = joints["right_hip"],
//           let ankle = joints["right_ankle"] {
//            let bodyAngle = calculateAngle(a: shoulder.point, b: hip.point, c: ankle.point)
//            angles["body_alignment"] = bodyAngle
//        }
//        
//        return angles
//    }
//    
//    private func calculateLungeAngles(joints: [String: BodyJoint]) -> [String: Float] {
//        var angles: [String: Float] = [:]
//        
//        if let rightHip = joints["right_hip"],
//           let rightKnee = joints["right_knee"],
//           let rightAnkle = joints["right_ankle"] {
//            let rightAngle = calculateAngle(a: rightHip.point, b: rightKnee.point, c: rightAnkle.point)
//            angles["front_knee_angle"] = rightAngle
//        }
//        
//        return angles
//    }
//    
//    private func calculateHipAbductionAngles(joints: [String: BodyJoint]) -> [String: Float] {
//        var angles: [String: Float] = [:]
//        
//        if let hip = joints["right_hip"],
//           let knee = joints["right_knee"] {
//            let separation = knee.point.x - hip.point.x
//            angles["leg_separation"] = Float(separation)
//        }
//        
//        return angles
//    }
//    
//    private func calculateHollowBodyAngles(joints: [String: BodyJoint]) -> [String: Float] {
//        var angles: [String: Float] = [:]
//        
//        if let shoulder = joints["right_shoulder"],
//           let hip = joints["right_hip"],
//           let knee = joints["right_knee"] {
//            let backAngle = calculateAngle(a: shoulder.point, b: hip.point, c: knee.point)
//            angles["back_angle"] = backAngle
//        }
//        
//        return angles
//    }
//    
//    private func calculateSupermanAngles(joints: [String: BodyJoint]) -> [String: Float] {
//        var angles: [String: Float] = [:]
//        
//        if let hip = joints["right_hip"],
//           let wrist = joints["right_wrist"],
//           let ankle = joints["right_ankle"] {
//            let armElevation = hip.point.y - wrist.point.y
//            let legElevation = hip.point.y - ankle.point.y
//            angles["arm_elevation"] = Float(armElevation)
//            angles["leg_elevation"] = Float(legElevation)
//        }
//        
//        return angles
//    }
//    
//    // MARK: - Result Printing (Console Output Only)
//    
//    private func printAnalysisResult(_ result: ExerciseAnalysisResult) {
//        print("\n" + String(repeating: "=", count: 60))
//        print("📊 EXERCISE ANALYSIS RESULT")
//        print(String(repeating: "=", count: 60))
//        print("Exercise: \(result.exerciseName) (ID: \(result.exerciseId))")
//        print("Timestamp: \(result.timestamp)")
//        print("Status: \(result.isCorrect ? "✅ CORRECT" : "❌ INCORRECT")")
//        print("Confidence: \(String(format: "%.1f%%", result.confidence * 100))")
//        
//        if !result.flags.isEmpty {
//            print("\n⚠️ Detected Issues:")
//            for (index, flag) in result.flags.enumerated() {
//                print("  \(index + 1). \(flag)")
//            }
//        } else {
//            print("\n✅ No issues detected! Form looks good.")
//        }
//        
//        print("\n📍 Joint Coordinates:")
//        for (name, point) in result.jointCoordinates.sorted(by: { $0.key < $1.key }) {
//            print("  \(name): (\(String(format: "%.2f", point.x)), \(String(format: "%.2f", point.y)))")
//        }
//        
//        if !result.jointAngles.isEmpty {
//            print("\n📐 Calculated Angles:")
//            for (name, angle) in result.jointAngles.sorted(by: { $0.key < $1.key }) {
//                print("  \(name): \(String(format: "%.1f°", angle))")
//            }
//        }
//        
//        print(String(repeating: "=", count: 60) + "\n")
//    }
//    
//    deinit {
//        stopCameraSession()
//    }
//}

import AVFoundation
import ImageIO
import Vision
import UIKit

// MARK: - Data Models

struct BodyJoint {
    let name: String
    let point: CGPoint        // Normalized 0-1, Y=0 top, Y=1 bottom (already flipped from Vision)
    let confidence: Float
    let visionJointName: VNHumanBodyPoseObservation.JointName
}

struct DetectedPose {
    var joints: [String: BodyJoint] = [:]
    var timestamp: Date = Date()
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
    let timestamp: Date = Date()
}

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

// NEW: Decode only the exercises array from the ruleset root so extra JSON sections do not break loading.
private struct ExerciseRulesetPayload: Codable {
    let exercises: [ExerciseRule]
}

// NEW: Encapsulates the camera-placement instructions derived from the JSON exercise rule.
struct CameraPlacementGuidance {
    let title: String
    let message: String
    let requiresLandscape: Bool
}

// NEW: Represents one scored ruleset check so the visible accuracy and the correction flags come from the same strategy path.
private struct ScoredRuleCheck {
    let flagKey: String
    let score: Double?
}

enum AnyCodable: Codable {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case array([AnyCodable])
    case object([String: AnyCodable])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Int.self)               { self = .int(v); return }
        if let v = try? container.decode(Double.self)            { self = .double(v); return }
        if let v = try? container.decode(String.self)            { self = .string(v); return }
        if let v = try? container.decode(Bool.self)              { self = .bool(v); return }
        if let v = try? container.decode([AnyCodable].self)      { self = .array(v); return }
        if let v = try? container.decode([String: AnyCodable].self) { self = .object(v); return }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode AnyCodable")
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .int(let v):    try c.encode(v)
        case .double(let v): try c.encode(v)
        case .string(let v): try c.encode(v)
        case .bool(let v):   try c.encode(v)
        case .array(let v):  try c.encode(v)
        case .object(let v): try c.encode(v)
        }
    }
}

// MARK: - ViewModel

@Observable
class ExerciseDetectionViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: Observable state
    var currentPose: DetectedPose = DetectedPose()
    var analysisResult: ExerciseAnalysisResult?
    // NEW: Keep a non-optional live form percentage for the UI so it updates even when the detailed result falls back.
    var liveFormPercent: Double = 0
    var jointOverlayPoints: [CGPoint] = []
    var cameraPermissionGranted = false
    var isAnalyzing = false
    var errorMessages: [String] = []

    // MARK: Internal (accessible to CameraFeedView)
    var captureSession: AVCaptureSession?
    // NEW: Expose the live preview rotation so PostureCheckView can keep the preview layer aligned with Vision.
    var previewRotationAngle: CGFloat {
        videoRotationAngle(for: currentInterfaceOrientation)
    }

    // MARK: Private
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private let sessionQueue   = DispatchQueue(label: "com.rep.sessionQueue",    qos: .userInitiated)
    private let processingQueue = DispatchQueue(label: "com.rep.processingQueue", qos: .userInitiated)

    private var exerciseRules: [ExerciseRule] = []
    private var currentExerciseId: Int = 1
    private let poseRequest = VNDetectHumanBodyPoseRequest()

    // Vision joint name → string key used in joints dict
    private let jointMapping: [String: VNHumanBodyPoseObservation.JointName] = [
        "nose":           .nose,
        "neck":           .neck,
        "right_shoulder": .rightShoulder,
        "right_elbow":    .rightElbow,
        "right_wrist":    .rightWrist,
        "left_shoulder":  .leftShoulder,
        "left_elbow":     .leftElbow,
        "left_wrist":     .leftWrist,
        "right_hip":      .rightHip,
        "right_knee":     .rightKnee,
        "right_ankle":    .rightAnkle,
        "left_hip":       .leftHip,
        "left_knee":      .leftKnee,
        "left_ankle":     .leftAnkle,
        "right_eye":      .rightEye,
        "left_eye":       .leftEye,
        "right_ear":      .rightEar,
        "left_ear":       .leftEar
    ]

//    // NEW: Read the active scene orientation instead of hardcoding portrait.
//    private var currentInterfaceOrientation: UIInterfaceOrientation {
//        UIApplication.shared.connectedScenes
//            .compactMap { $0 as? UIWindowScene }
//            .first(where: { $0.activationState == .foregroundActive })?
//            .interfaceOrientation ?? .portrait
//    }
    // NEW: Read scene orientation through a main-thread-safe helper so camera setup does not trip Main Thread Checker.
    private var currentInterfaceOrientation: UIInterfaceOrientation {
        currentInterfaceOrientationFromMainThread()
    }

    // MARK: Init
    override init() {
        super.init()
        loadExerciseRules()
        checkCameraPermission()
    }

    // MARK: - Camera Permission

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async { self?.cameraPermissionGranted = granted }
            }
        default:
            cameraPermissionGranted = false
        }
    }

    // NEW: Map the current interface orientation into AVCapture's rotation-angle API.
    private func videoRotationAngle(for orientation: UIInterfaceOrientation) -> CGFloat {
        switch orientation {
        case .portrait:
            return 90
        case .portraitUpsideDown:
            return 270
        case .landscapeLeft:
            return 180
        case .landscapeRight:
            return 0
        default:
            return 90
        }
    }

    // NEW: Access UIApplication/UIWindowScene only on the main thread, even when camera work runs on background queues.
    private func currentInterfaceOrientationFromMainThread() -> UIInterfaceOrientation {
        if Thread.isMainThread {
            return activeWindowSceneInterfaceOrientation()
        }

        return DispatchQueue.main.sync {
            activeWindowSceneInterfaceOrientation()
        }
    }

    // NEW: Isolate UIKit scene inspection in one place for the main-thread-safe orientation lookup.
    private func activeWindowSceneInterfaceOrientation() -> UIInterfaceOrientation {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .interfaceOrientation ?? .portrait
    }

    // NEW: Map the current interface orientation into Vision's image orientation for the mirrored front camera.
    private func visionOrientation(for orientation: UIInterfaceOrientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .portrait:
            return .leftMirrored
        case .portraitUpsideDown:
            return .rightMirrored
        case .landscapeLeft:
            return .upMirrored
        case .landscapeRight:
            return .downMirrored
        default:
            return .leftMirrored
        }
    }

    // MARK: - Camera Session

    func startCameraSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            let session = AVCaptureSession()
            session.beginConfiguration()
            session.sessionPreset = .high

            // Front camera
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .front),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                print("❌ Cannot set up front camera input")
                session.commitConfiguration()
                return
            }
            session.addInput(input)

            // Video output
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: self.processingQueue)
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            output.alwaysDiscardsLateVideoFrames = true

            guard session.canAddOutput(output) else {
                print("❌ Cannot set up video output")
                session.commitConfiguration()
                return
            }
            session.addOutput(output)

//            // ✅ Fix orientation — front camera portrait = 90° rotation
//            if let connection = output.connection(with: .video) {
//                if connection.isVideoRotationAngleSupported(90) {
//                    connection.videoRotationAngle = 90   // portrait upright
//                }
//                // ✅ Mirror the preview connection so left/right appear natural
//                if connection.isVideoMirroringSupported {
//                    connection.isVideoMirrored = true
//                }
//            }
            // NEW: Configure the output connection from the current interface orientation instead of forcing portrait.
            if let connection = output.connection(with: .video) {
                let rotationAngle = self.videoRotationAngle(for: self.currentInterfaceOrientation)
                if connection.isVideoRotationAngleSupported(rotationAngle) {
                    connection.videoRotationAngle = rotationAngle
                }
//                if connection.isVideoMirroringSupported {
//                    connection.isVideoMirrored = true
//                }
                // NEW: Turn off automatic mirroring before setting front-camera mirroring manually to avoid AVCaptureConnection exceptions.
                if connection.isVideoMirroringSupported {
                    connection.automaticallyAdjustsVideoMirroring = false
                    connection.isVideoMirrored = true
                }
            }

            session.commitConfiguration()

            // ✅ Publish session on main so CameraFeedView can attach preview layer
            DispatchQueue.main.async {
                self.captureSession = session
                self.videoDataOutput = output
                self.isAnalyzing = true
            }

            // ✅ startRunning() stays on sessionQueue (background) — NOT main thread
            session.startRunning()
            print("✅ Camera session started")
        }
    }

    func stopCameraSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                self?.currentPose = DetectedPose()
                self?.analysisResult = nil
            }
            print("✅ Camera session stopped")
        }
    }

    // MARK: - Exercise Rules

    private func loadExerciseRules() {
        guard let url = Bundle.main.url(forResource: "ExerciseRuleset", withExtension: "json") else {
            print("❌ ExerciseRuleset.json not found — check Target Membership")
            return
        }
        do {
            let data = try Data(contentsOf: url)
//            let decoded = try JSONDecoder().decode([String: [ExerciseRule]].self, from: data)
//            exerciseRules = decoded["exercises"] ?? []
            // NEW: Decode the real ruleset root object so the bundled joint-definition metadata does not make parsing fail.
            let decoded = try JSONDecoder().decode(ExerciseRulesetPayload.self, from: data)
            exerciseRules = decoded.exercises
            print("✅ Loaded \(exerciseRules.count) exercise rules")
        } catch {
            print("❌ JSON parse error: \(error)")
        }
    }

    func setCurrentExercise(id: Int) {
        guard id > 0 && id <= 14 else {
            print("❌ Invalid exercise ID: \(id)")
            return
        }
        guard !exerciseRules.isEmpty, id <= exerciseRules.count else {
            print("⚠️ Rules not loaded yet for ID \(id)")
            return
        }
        currentExerciseId = id
        errorMessages.removeAll()
        analysisResult = nil
        // NEW: Reset the visible score when switching exercises so the next live pose computes from a clean state.
        liveFormPercent = 0
        print("📋 Exercise set: \(exerciseRules[id - 1].name)")
    }

    // NEW: Surface a user-facing placement hint from the current JSON rule so PostureCheckView can guide camera setup.
    var currentCameraGuidance: CameraPlacementGuidance {
        guard !exerciseRules.isEmpty,
              currentExerciseId > 0,
              currentExerciseId <= exerciseRules.count else {
            return CameraPlacementGuidance(
                title: "Set Up Camera",
                message: "Keep your full body in frame with enough distance to see your major joints clearly.",
                requiresLandscape: false
            )
        }

        let rule = exerciseRules[currentExerciseId - 1]
        let isLandscape = currentInterfaceOrientation.isLandscape

        switch rule.camera_angle {
        case "side":
            return CameraPlacementGuidance(
                title: isLandscape ? "Side View Ready" : "Rotate Phone Sideways",
                message: isLandscape
                    ? "Keep the phone in landscape, place it at hip-to-chest height from your side, and fit your full body in frame."
                    : "This exercise needs a side view. Rotate the phone to landscape and place it beside you at hip-to-chest height so your whole body is visible.",
                requiresLandscape: true
            )
        case "front":
            return CameraPlacementGuidance(
                title: "Face the Camera",
                message: "Keep the phone upright in portrait, place it directly in front of you at chest height, and keep your full body inside the frame.",
                requiresLandscape: false
            )
        case "front_or_side":
            return CameraPlacementGuidance(
                title: "Front View Preferred",
                message: "Start with the phone upright in front of you at chest height. If the full body does not fit well, switch to a clear side angle with enough distance.",
                requiresLandscape: false
            )
        default:
            return CameraPlacementGuidance(
                title: "Set Up Camera",
                message: "Keep your full body in frame and avoid cutting off shoulders, hips, knees, or ankles.",
                requiresLandscape: false
            )
        }
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

//        // ✅ .leftMirrored = front camera in portrait with hardware mirroring
//        // Vision will interpret the buffer correctly so joint coords match the preview
//        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
//                                            orientation: .leftMirrored,
//                                            options: [:])
        // NEW: Update capture orientation per frame so portrait and landscape overlays match the live camera feed.
        let interfaceOrientation = currentInterfaceOrientation
        let rotationAngle = videoRotationAngle(for: interfaceOrientation)
        if connection.isVideoRotationAngleSupported(rotationAngle) {
            connection.videoRotationAngle = rotationAngle
        }
//        if connection.isVideoMirroringSupported {
//            connection.isVideoMirrored = true
//        }
        // NEW: Disable automatic mirroring on the live connection before applying the manual mirrored front-camera orientation.
        if connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }

        // NEW: Feed Vision the matching orientation for the mirrored front camera instead of assuming portrait.
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: visionOrientation(for: interfaceOrientation),
            options: [:]
        )
        do {
            try handler.perform([poseRequest])
            guard let observation = poseRequest.results?.first else { return }
            processPose(observation)   // already on processingQueue
        } catch {
            print("⚠️ Pose detection error: \(error)")
        }
    }

    // MARK: - Pose Processing

    private func processPose(_ observation: VNHumanBodyPoseObservation) {
        var pose = DetectedPose()
        pose.isValid = true

        for (name, visionName) in jointMapping {
            guard let pt = try? observation.recognizedPoint(visionName),
                  pt.confidence > 0.3 else { continue }

            // ✅ Flip Y only — Vision origin is bottom-left, screen is top-left.
            //    X is already correct because we used .leftMirrored + mirrored connection.
            let joint = BodyJoint(
                name: name,
                point: CGPoint(x: pt.location.x, y: 1.0 - pt.location.y),
                confidence: Float(pt.confidence),
                visionJointName: visionName
            )
            pose.joints[name] = joint
        }

        // Analyse synchronously here (processingQueue) — joints are local, no race
        let joints = pose.joints
        let coords = joints.mapValues { $0.point }
        let result = buildAnalysisResult(joints: joints, coordinates: coords)

        DispatchQueue.main.async { [weak self] in
            self?.currentPose = pose
            self?.jointOverlayPoints = pose.joints.values.map { $0.point }
            // NEW: Always publish the latest score and rule feedback from the live pose analysis.
            self?.analysisResult = result
            self?.liveFormPercent = Double(result.confidence) * 100
        }
    }

    // MARK: - Analysis

    private func buildAnalysisResult(joints: [String: BodyJoint],
                                     coordinates: [String: CGPoint]) -> ExerciseAnalysisResult {
        guard !joints.isEmpty else {
            return ExerciseAnalysisResult(
                exerciseId: currentExerciseId,
                exerciseName: currentExerciseName,
                isCorrect: false,
                confidence: 0,
                flags: ["Move into frame. Keep your full body visible to start posture analysis."],
                jointCoordinates: coordinates,
                jointAngles: [:]
            )
        }

        guard !exerciseRules.isEmpty,
              currentExerciseId > 0,
              currentExerciseId <= exerciseRules.count else {
            let fallbackConfidence = min(Float(joints.count) / Float(max(jointMapping.count, 1)), 0.65)
            return ExerciseAnalysisResult(
                exerciseId: currentExerciseId,
                exerciseName: currentExerciseName,
                isCorrect: false,
                confidence: fallbackConfidence,
                flags: ["Ruleset unavailable. Keep your full body in frame and hold the exercise steadily."],
                jointCoordinates: coordinates,
                jointAngles: [:]
            )
        }

        let exercise = exerciseRules[currentExerciseId - 1]
        //        var flags: [String] = []
        //        var angles: [String: Float] = [:]
        //
        //        switch currentExerciseId {
        //        case 1:  flags = validatePlank(exercise: exercise, joints: joints);          angles = calcPlankAngles(joints)
        //        case 2:  flags = validateWallSit(exercise: exercise, joints: joints);        angles = calcKneeAngles(joints)
        //        case 3:  flags = validateStaticSquat(exercise: exercise, joints: joints);    angles = calcKneeAngles(joints)
        //        case 4:  flags = validateGlueBridge(exercise: exercise, joints: joints);     angles = calcHipAngles(joints)
        //        case 5:  flags = validateDeadHang(exercise: exercise, joints: joints);       angles = calcArmAngles(joints)
        //        case 6:  flags = validateOverheadHold(exercise: exercise, joints: joints);   angles = calcArmAngles(joints)
        //        case 7:  flags = validateHighPlank(exercise: exercise, joints: joints);      angles = calcPlankAngles(joints)
        //        case 8:  flags = validateLowPlank(exercise: exercise, joints: joints);       angles = calcForearmPlankAngles(joints)
        //        case 9:  flags = validateSidePlank(exercise: exercise, joints: joints);      angles = calcPlankAngles(joints)
        //        case 10: flags = validateLungeHold(exercise: exercise, joints: joints);      angles = calcLungeAngles(joints)
        //        case 11: flags = validateHipAbduction(exercise: exercise, joints: joints);   angles = calcHipAbductionAngles(joints)
        //        case 12: flags = validateLSit(exercise: exercise, joints: joints);           angles = calcHipAngles(joints)
        //        case 13: flags = validateHollowBody(exercise: exercise, joints: joints);     angles = calcHollowBodyAngles(joints)
        //        case 14: flags = validateSuperman(exercise: exercise, joints: joints);       angles = calcSupermanAngles(joints)
        //        default: flags.append("Unknown exercise ID")
        //        }
        // NEW: Drive the live result from scored strategy checks so the accuracy percent and the correction messages come from the same ruleset path.
        let angles = strategyAngles(for: currentExerciseId, joints: joints)
        let checks = strategyChecks(for: exercise, joints: joints, angles: angles)
        let flags = feedbackFlags(from: checks, exercise: exercise)

//        let confidence = continuousConfidenceScore(
//            for: currentExerciseId,
//            joints: joints,
//            angles: angles,
//            flags: flags
//        )
        // NEW: Convert the scored ruleset checks into a stable, nonzero live accuracy value calibrated by the exercise strategy.
        let confidence = strategyConfidenceScore(
            exercise: exercise,
            joints: joints,
            checks: checks
        )
        return ExerciseAnalysisResult(
            exerciseId: currentExerciseId,
            exerciseName: exercise.name,
            isCorrect: flags.isEmpty,
            confidence: confidence,
            flags: flags,
            jointCoordinates: coordinates,
            jointAngles: angles
        )
    }

    // MARK: - Strategy-Driven Analysis

    // NEW: Extract the per-exercise measurements used by the scored ruleset checks.
    private func strategyAngles(for exerciseId: Int, joints: [String: BodyJoint]) -> [String: Float] {
        switch exerciseId {
        case 1, 7, 9:
            return calcPlankAngles(joints)
        case 2, 3:
            return calcKneeAngles(joints)
        case 4, 12:
            return calcHipAngles(joints)
        case 5, 6:
            return calcArmAngles(joints)
        case 8:
            return calcForearmPlankAngles(joints)
        case 10:
            return calcLungeAngles(joints)
        case 11:
            return calcHipAbductionAngles(joints)
        case 13:
            return calcHollowBodyAngles(joints)
        case 14:
            return calcSupermanAngles(joints)
        default:
            return [:]
        }
    }

    // NEW: Score each exercise exactly as a set of posture checks so the percent reflects how well the current pose matches the strategy.
    private func strategyChecks(
        for exercise: ExerciseRule,
        joints: [String: BodyJoint],
        angles: [String: Float]
    ) -> [ScoredRuleCheck] {
        switch exercise.id {
        case 1:
            let bodyThreshold = ruleFloat(exercise, "body_alignment_threshold") ?? 15
            let armThreshold = ruleFloat(exercise, "arm_angle_threshold") ?? 160
            return [
                ScoredRuleCheck(flagKey: "misaligned_body", score: scoreTarget(primaryBodyAlignmentAngle(from: joints), target: 180, tolerance: bodyThreshold)),
                ScoredRuleCheck(flagKey: "sagging_hips", score: scoreMax(primaryHipShoulderOffset(from: joints), maxValue: 0.06, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "bent_elbows", score: scoreMin(averageArmAngle(from: joints), minValue: armThreshold, softTolerance: 18))
            ]
        case 2:
            let minAngle = ruleFloat(exercise, "knee_angle_min") ?? 85
            let maxAngle = ruleFloat(exercise, "knee_angle_max") ?? 95
            return [
                ScoredRuleCheck(flagKey: "knee_angle_incorrect", score: scoreRange(averageKneeAngle(from: joints), minValue: minAngle, maxValue: maxAngle, softTolerance: 12)),
                ScoredRuleCheck(flagKey: "back_tilted", score: scoreMax(primaryShoulderHipHorizontalOffset(from: joints), maxValue: 0.08, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "hips_too_high", score: scoreMin(primaryHipDepthRelativeToKnee(from: joints), minValue: 0.0, softTolerance: 0.10))
            ]
        case 3:
            let minAngle = ruleFloat(exercise, "knee_angle_min") ?? 80
            let maxAngle = ruleFloat(exercise, "knee_angle_max") ?? 100
            return [
                ScoredRuleCheck(flagKey: "knee_angle_incorrect", score: scoreRange(averageKneeAngle(from: joints), minValue: minAngle, maxValue: maxAngle, softTolerance: 15)),
                ScoredRuleCheck(flagKey: "torso_tilted", score: scoreMax(primaryShoulderHipHorizontalOffset(from: joints), maxValue: 0.10, softTolerance: 0.12)),
                ScoredRuleCheck(flagKey: "hips_too_high", score: scoreMin(primaryHipDepthRelativeToKnee(from: joints), minValue: 0.0, softTolerance: 0.10))
            ]
        case 4:
            let bridgeAngle = ruleFloat(exercise, "shoulder_hip_knee_angle_min") ?? 160
            return [
                ScoredRuleCheck(flagKey: "hips_not_elevated", score: scoreMin(primaryBridgeLift(from: joints), minValue: 0.02, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "hips_sagging", score: scoreMin(primaryBridgeAngle(from: joints), minValue: bridgeAngle, softTolerance: 18))
            ]
        case 5:
            let armThreshold = ruleFloat(exercise, "arm_angle_threshold") ?? 160
            return [
                ScoredRuleCheck(flagKey: "elbows_bent", score: scoreMin(minimumArmAngle(from: joints), minValue: armThreshold, softTolerance: 15)),
                ScoredRuleCheck(flagKey: "wrists_below_shoulders", score: scoreMin(minimumWristAboveShoulderLift(from: joints), minValue: 0.0, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "body_swinging", score: scoreTarget(primaryBodyAlignmentAngle(from: joints), target: 180, tolerance: 20))
            ]
        case 6:
            let armThreshold = ruleFloat(exercise, "arm_angle_threshold") ?? 160
            return [
                ScoredRuleCheck(flagKey: "elbows_bent", score: scoreMin(minimumArmAngle(from: joints), minValue: armThreshold, softTolerance: 15)),
                ScoredRuleCheck(flagKey: "wrists_forward", score: scoreMin(minimumWristAboveHeadLift(from: joints), minValue: 0.0, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "core_not_engaged", score: scoreMax(primaryShoulderHipHorizontalOffset(from: joints), maxValue: 0.08, softTolerance: 0.10))
            ]
        case 7:
            let armThreshold = ruleFloat(exercise, "arm_angle_threshold") ?? 160
            return [
                ScoredRuleCheck(flagKey: "body_misaligned", score: scoreTarget(primaryBodyAlignmentAngle(from: joints), target: 180, tolerance: 15)),
                ScoredRuleCheck(flagKey: "hips_sagging", score: scoreMax(primaryHipShoulderOffset(from: joints), maxValue: 0.06, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "elbows_bent", score: scoreMin(minimumArmAngle(from: joints), minValue: armThreshold, softTolerance: 15)),
                ScoredRuleCheck(flagKey: "shoulders_over_wrists", score: scoreMax(primaryShoulderWristHorizontalOffset(from: joints), maxValue: 0.08, softTolerance: 0.08))
            ]
        case 8:
            return [
                ScoredRuleCheck(flagKey: "body_misaligned", score: scoreTarget(primaryBodyAlignmentAngle(from: joints), target: 180, tolerance: 15)),
                ScoredRuleCheck(flagKey: "hips_sagging", score: scoreMax(primaryHipShoulderOffset(from: joints), maxValue: 0.06, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "elbows_not_90", score: scoreTarget(primaryForearmElbowAngle(from: joints), target: 90, tolerance: 15)),
                ScoredRuleCheck(flagKey: "shoulder_not_stacked", score: scoreMax(primaryShoulderElbowHorizontalOffset(from: joints), maxValue: 0.08, softTolerance: 0.08))
            ]
        case 9:
            return [
                ScoredRuleCheck(flagKey: "not_straight_line", score: scoreMax(primarySidePlankLineDeviation(from: joints), maxValue: 0.15, softTolerance: 0.12)),
                ScoredRuleCheck(flagKey: "hip_sagging", score: scoreMax(primarySidePlankHipSag(from: joints), maxValue: 0.08, softTolerance: 0.08)),
                ScoredRuleCheck(flagKey: "body_leaning_forward", score: scoreMax(primaryShoulderHipHorizontalOffset(from: joints), maxValue: 0.10, softTolerance: 0.10))
            ]
        case 10:
            let minAngle = ruleFloat(exercise, "front_knee_angle_min") ?? 85
            let maxAngle = ruleFloat(exercise, "front_knee_angle_max") ?? 95
            return [
                ScoredRuleCheck(flagKey: "front_knee_angle_incorrect", score: scoreRange(primaryFrontKneeAngle(from: joints), minValue: minAngle, maxValue: maxAngle, softTolerance: 12)),
                ScoredRuleCheck(flagKey: "back_knee_too_high", score: scoreMin(primaryBackKneeGroundDepth(from: joints), minValue: 0.72, softTolerance: 0.14)),
                ScoredRuleCheck(flagKey: "torso_tilted", score: scoreMax(primaryTorsoUprightOffsetForLunge(from: joints), maxValue: 0.10, softTolerance: 0.10))
            ]
        case 11:
            return [
                ScoredRuleCheck(flagKey: "leg_not_raised_enough", score: scoreMin(primaryLegSeparation(from: joints), minValue: 0.12, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "standing_leg_bent", score: scoreMin(primaryStandingLegAngle(from: joints), minValue: 160, softTolerance: 20)),
                ScoredRuleCheck(flagKey: "hip_dropping", score: scoreMax(hipLevelDifference(joints), maxValue: 0.06, softTolerance: 0.06))
            ]
        case 12:
            return [
                ScoredRuleCheck(flagKey: "hip_angle_incorrect", score: scoreTarget(angles["hip_angle"], target: 90, tolerance: 15)),
                ScoredRuleCheck(flagKey: "legs_sagging", score: scoreMax(primaryLSitLegSag(from: joints), maxValue: 0.08, softTolerance: 0.08)),
                ScoredRuleCheck(flagKey: "elbows_bent", score: scoreMin(minimumArmAngle(from: joints), minValue: 160, softTolerance: 15))
            ]
        case 13:
            return [
                ScoredRuleCheck(flagKey: "lower_back_arched", score: scoreTarget(angles["back_angle"], target: 180, tolerance: 15)),
                ScoredRuleCheck(flagKey: "legs_not_raised", score: scoreMin(primaryLegElevation(from: joints), minValue: 0.04, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "arms_not_overhead", score: scoreMin(primaryArmElevation(from: joints), minValue: 0.0, softTolerance: 0.10))
            ]
        case 14:
            return [
                ScoredRuleCheck(flagKey: "arms_not_elevated", score: scoreMin(primaryArmElevation(from: joints), minValue: 0.05, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "legs_not_elevated", score: scoreMin(primaryLegElevation(from: joints), minValue: 0.05, softTolerance: 0.10)),
                ScoredRuleCheck(flagKey: "chest_not_lifted", score: scoreMin(primaryChestLift(from: joints), minValue: 0.04, softTolerance: 0.10))
            ]
        default:
            return []
        }
    }

    // NEW: Turn failed strategy checks into issue/fix feedback for the card.
    private func feedbackFlags(from checks: [ScoredRuleCheck], exercise: ExerciseRule) -> [String] {
        let threshold = 0.72
        var flags: [String] = []

        for check in checks {
            guard let score = check.score, score < threshold else { continue }
            let message = flagMessage(for: check.flagKey, in: exercise)
            if !flags.contains(message) {
                flags.append(message)
            }
        }

        if flags.isEmpty, checks.compactMap(\.score).isEmpty {
            return ["Move into frame. Keep your full body visible so the app can evaluate your posture."]
        }

        return flags
    }

    // NEW: Calibrate the visible accuracy from the scored posture checks instead of a flat flag count.
    private func strategyConfidenceScore(
        exercise: ExerciseRule,
        joints: [String: BodyJoint],
        checks: [ScoredRuleCheck]
    ) -> Float {
        let checkScores = checks.compactMap(\.score)
        let rulesScore = checkScores.isEmpty ? 0.0 : (checkScores.reduce(0.0, +) / Double(checkScores.count))
        let poseCoverageScore = min(Double(joints.count) / Double(jointMapping.count), 1.0)
        let jointConfidenceScore = averageJointConfidence(from: joints)

        let blended = (rulesScore * 0.80) + (poseCoverageScore * 0.12) + (jointConfidenceScore * 0.08)
        let calibratedFloor: Double

        switch rulesScore {
        case 0.95...:
            calibratedFloor = exercise.expected_accuracy
        case 0.85..<0.95:
            calibratedFloor = max(exercise.expected_accuracy - 0.08, 0.72)
        case 0.70..<0.85:
            calibratedFloor = 0.58
        case 0.55..<0.70:
            calibratedFloor = 0.42
        case 0.35..<0.55:
            calibratedFloor = 0.28
        default:
            calibratedFloor = joints.isEmpty ? 0.0 : 0.18
        }

        return Float(min(max(blended, calibratedFloor), 0.99))
    }

    // NEW: Read numeric rule values directly from the JSON ruleset.
    private func ruleFloat(_ exercise: ExerciseRule, _ key: String) -> Float? {
        guard let value = exercise.rules[key] else { return nil }
        switch value {
        case .int(let intValue):
            return Float(intValue)
        case .double(let doubleValue):
            return Float(doubleValue)
        default:
            return nil
        }
    }

    // NEW: Normalize feedback strings so the card can always show both the issue and how to correct it.
    private func flagMessage(for key: String, in exercise: ExerciseRule) -> String {
        let rawMessage = exercise.flags[key]
            ?? (key == "bent_elbows" ? exercise.flags["qbent_elbows"] : nil)
            ?? key.replacingOccurrences(of: "_", with: " ").capitalized

        return enrichedFeedbackMessage(rawMessage)
    }

    // NEW: Guarantee that each message contains a clear correction sentence for the UI.
    private func enrichedFeedbackMessage(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "Form issue detected. Adjust your position and hold the target posture again."
        }

        if trimmed.contains(".") {
            return trimmed
        }

        let lower = trimmed.lowercased()
        if lower.contains("cannot detect") || lower.contains("move into frame") {
            return "\(trimmed). Step back and keep your full body visible in the camera."
        }
        if lower.contains("straight") || lower.contains("bent") {
            return "\(trimmed). Straighten the joint and hold the position steady."
        }
        if lower.contains("sagging") || lower.contains("dropping") || lower.contains("too high") {
            return "\(trimmed). Adjust your hips until your body line looks level."
        }
        if lower.contains("upright") || lower.contains("tilted") || lower.contains("leaning") {
            return "\(trimmed). Bring your torso back to a tall, neutral position."
        }
        if lower.contains("raised") || lower.contains("overhead") || lower.contains("elevated") {
            return "\(trimmed). Lift the limb higher until it reaches the target position."
        }
        if lower.contains("stacked") || lower.contains("over") {
            return "\(trimmed). Stack the joints vertically before holding the pose."
        }
        return "\(trimmed). Adjust the pose until the highlighted joint positions match the target hold."
    }

    // NEW: Score a value that should stay inside a target range.
    private func scoreRange(_ value: Float?, minValue: Float, maxValue: Float, softTolerance: Float) -> Double? {
        guard let value else { return nil }
        if value >= minValue && value <= maxValue {
            return 1.0
        }
        if value < minValue {
            let underflow = min((minValue - value) / softTolerance, 1)
            return Double(1 - underflow)
        }
        let overflow = min((value - maxValue) / softTolerance, 1)
        return Double(1 - overflow)
    }

    // NEW: Pick the average side-body angle so side-view exercises work regardless of which side is clearer.
    private func primaryBodyAlignmentAngle(from joints: [String: BodyJoint]) -> Float? {
        averageOptional(compactMeasurements([
            bodyAlignmentAngle(from: joints, prefix: "right"),
            bodyAlignmentAngle(from: joints, prefix: "left")
        ]))
    }

    // NEW: Measure how level the hips are relative to the shoulders across whichever side is visible best.
    private func primaryHipShoulderOffset(from joints: [String: BodyJoint]) -> CGFloat? {
        averageCGFloat(compactMeasurements([
            hipShoulderOffset(from: joints, prefix: "right"),
            hipShoulderOffset(from: joints, prefix: "left")
        ]))
    }

    // NEW: Measure torso tilt using the clearest shoulder-hip pair.
    private func primaryShoulderHipHorizontalOffset(from joints: [String: BodyJoint]) -> CGFloat? {
        averageCGFloat(compactMeasurements([
            shoulderHipHorizontalOffset(from: joints, prefix: "right"),
            shoulderHipHorizontalOffset(from: joints, prefix: "left")
        ]))
    }

    // NEW: Estimate squat or wall-sit depth by comparing hip and knee height on both sides.
    private func primaryHipDepthRelativeToKnee(from joints: [String: BodyJoint]) -> CGFloat? {
        averageCGFloat(compactMeasurements([
            hipDepthRelativeToKnee(from: joints, prefix: "right"),
            hipDepthRelativeToKnee(from: joints, prefix: "left")
        ]))
    }

    // NEW: Average both elbow angles for two-arm holds.
    private func averageArmAngle(from joints: [String: BodyJoint]) -> Float? {
        averageOptional(compactMeasurements([
            armAngle(from: joints, prefix: "right"),
            armAngle(from: joints, prefix: "left")
        ]))
    }

    // NEW: Use the smaller arm angle so a single bent arm can lower the score.
    private func minimumArmAngle(from joints: [String: BodyJoint]) -> Float? {
        compactMeasurements([
            armAngle(from: joints, prefix: "right"),
            armAngle(from: joints, prefix: "left")
        ]).min()
    }

    // NEW: Measure how far above the shoulders the wrists are for hangs.
    private func minimumWristAboveShoulderLift(from joints: [String: BodyJoint]) -> CGFloat? {
        compactMeasurements([
            wristAboveShoulderLift(from: joints, prefix: "right"),
            wristAboveShoulderLift(from: joints, prefix: "left")
        ]).min()
    }

    // NEW: Measure how far above the head the wrists are for overhead holds.
    private func minimumWristAboveHeadLift(from joints: [String: BodyJoint]) -> CGFloat? {
        compactMeasurements([
            wristAboveHeadLift(from: joints, prefix: "right"),
            wristAboveHeadLift(from: joints, prefix: "left")
        ]).min()
    }

    // NEW: Keep wrists and shoulders stacked for a high plank.
    private func primaryShoulderWristHorizontalOffset(from joints: [String: BodyJoint]) -> CGFloat? {
        averageCGFloat(compactMeasurements([
            shoulderWristHorizontalOffset(from: joints, prefix: "right"),
            shoulderWristHorizontalOffset(from: joints, prefix: "left")
        ]))
    }

    // NEW: Keep elbows under shoulders in a forearm plank.
    private func primaryShoulderElbowHorizontalOffset(from joints: [String: BodyJoint]) -> CGFloat? {
        averageCGFloat(compactMeasurements([
            shoulderElbowHorizontalOffset(from: joints, prefix: "right"),
            shoulderElbowHorizontalOffset(from: joints, prefix: "left")
        ]))
    }

    // NEW: Use the clearest elbow angle for the forearm-plank 90-degree check.
    private func primaryForearmElbowAngle(from joints: [String: BodyJoint]) -> Float? {
        averageOptional(compactMeasurements([
            forearmElbowAngle(from: joints, prefix: "right"),
            forearmElbowAngle(from: joints, prefix: "left")
        ]))
    }

    // NEW: Average bridge lift across sides.
    private func primaryBridgeLift(from joints: [String: BodyJoint]) -> CGFloat? {
        averageCGFloat(compactMeasurements([
            bridgeLift(from: joints, prefix: "right"),
            bridgeLift(from: joints, prefix: "left")
        ]))
    }

    // NEW: Average the bridge body-line angle across sides.
    private func primaryBridgeAngle(from joints: [String: BodyJoint]) -> Float? {
        averageOptional(compactMeasurements([
            bridgeAngle(from: joints, prefix: "right"),
            bridgeAngle(from: joints, prefix: "left")
        ]))
    }

    // NEW: Score side plank from whichever side joints are most visible.
    private func primarySidePlankLineDeviation(from joints: [String: BodyJoint]) -> CGFloat? {
        compactMeasurements([
            sidePlankLineDeviation(from: joints, prefix: "right"),
            sidePlankLineDeviation(from: joints, prefix: "left")
        ]).min()
    }

    // NEW: Score side plank hip sag from whichever side joints are most visible.
    private func primarySidePlankHipSag(from joints: [String: BodyJoint]) -> CGFloat? {
        compactMeasurements([
            sidePlankHipSag(from: joints, prefix: "right"),
            sidePlankHipSag(from: joints, prefix: "left")
        ]).min()
    }

    // NEW: Choose the deeper bent knee as the front leg for lunges.
    private func primaryFrontKneeAngle(from joints: [String: BodyJoint]) -> Float? {
        let candidates = lungeCandidates(from: joints)
        return candidates.min(by: { abs($0.kneeAngle - 90) < abs($1.kneeAngle - 90) })?.kneeAngle
    }

    // NEW: The other lunge knee should stay close to the ground.
    private func primaryBackKneeGroundDepth(from joints: [String: BodyJoint]) -> CGFloat? {
        guard let frontSide = lungeCandidates(from: joints).min(by: { abs($0.kneeAngle - 90) < abs($1.kneeAngle - 90) })?.side else {
            return nil
        }
        let backSide = frontSide == "right" ? "left" : "right"
        return joints["\(backSide)_knee"]?.point.y
    }

    // NEW: Use the front-leg torso column for the lunge torso-upright cue.
    private func primaryTorsoUprightOffsetForLunge(from joints: [String: BodyJoint]) -> CGFloat? {
        guard let frontSide = lungeCandidates(from: joints).min(by: { abs($0.kneeAngle - 90) < abs($1.kneeAngle - 90) })?.side else {
            return nil
        }
        return shoulderHipHorizontalOffset(from: joints, prefix: frontSide)
    }

    // NEW: Use the leg with the bigger lateral lift as the working leg in hip abduction.
    private func primaryLegSeparation(from joints: [String: BodyJoint]) -> Float? {
        let candidates = hipAbductionCandidates(from: joints)
        return candidates.max(by: { $0.separation < $1.separation })?.separation
    }

    // NEW: Use the opposite leg as the standing support leg in hip abduction.
    private func primaryStandingLegAngle(from joints: [String: BodyJoint]) -> Float? {
        guard let liftedSide = hipAbductionCandidates(from: joints).max(by: { $0.separation < $1.separation })?.side else {
            return nil
        }
        let standingSide = liftedSide == "right" ? "left" : "right"
        return standingLegAngle(from: joints, prefix: standingSide)
    }

    // NEW: Use the average knee-to-hip sag across both legs in an L-sit.
    private func primaryLSitLegSag(from joints: [String: BodyJoint]) -> CGFloat? {
        averageCGFloat(compactMeasurements([
            lsitLegSag(from: joints, prefix: "right"),
            lsitLegSag(from: joints, prefix: "left")
        ]))
    }

    // NEW: Use the stronger visible limb elevation for hollow body and superman checks.
    private func primaryArmElevation(from joints: [String: BodyJoint]) -> CGFloat? {
        compactMeasurements([
            limbElevation(from: joints, anchorPrefix: "right", limb: "wrist"),
            limbElevation(from: joints, anchorPrefix: "left", limb: "wrist")
        ]).max()
    }

    // NEW: Use the stronger visible leg elevation for hollow body and superman checks.
    private func primaryLegElevation(from joints: [String: BodyJoint]) -> CGFloat? {
        compactMeasurements([
            limbElevation(from: joints, anchorPrefix: "right", limb: "ankle"),
            limbElevation(from: joints, anchorPrefix: "left", limb: "ankle")
        ]).max()
    }

    // NEW: Use shoulder lift above the hip to represent chest lift in superman.
    private func primaryChestLift(from joints: [String: BodyJoint]) -> CGFloat? {
        compactMeasurements([
            chestLift(from: joints, prefix: "right"),
            chestLift(from: joints, prefix: "left")
        ]).max()
    }

    // NEW: Average both knee angles for squat-like holds.
    private func averageKneeAngle(from joints: [String: BodyJoint]) -> Float? {
        averageOptional(compactMeasurements([
            kneeAngle(from: joints, prefix: "right"),
            kneeAngle(from: joints, prefix: "left")
        ]))
    }

    // NEW: Common helper for side-body alignment.
    private func bodyAlignmentAngle(from joints: [String: BodyJoint], prefix: String) -> Float? {
        guard let shoulder = joints["\(prefix)_shoulder"],
              let hip = joints["\(prefix)_hip"],
              let ankle = joints["\(prefix)_ankle"] else { return nil }
        return calculateAngle(a: shoulder.point, b: hip.point, c: ankle.point)
    }

    // NEW: Common helper for hip level in planks.
    private func hipShoulderOffset(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let shoulder = joints["\(prefix)_shoulder"],
              let hip = joints["\(prefix)_hip"] else { return nil }
        return abs(hip.point.y - shoulder.point.y)
    }

    // NEW: Common helper for torso verticality checks.
    private func shoulderHipHorizontalOffset(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let shoulder = joints["\(prefix)_shoulder"],
              let hip = joints["\(prefix)_hip"] else { return nil }
        return abs(shoulder.point.x - hip.point.x)
    }

    // NEW: Common helper for squat and wall-sit depth checks.
    private func hipDepthRelativeToKnee(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let hip = joints["\(prefix)_hip"],
              let knee = joints["\(prefix)_knee"] else { return nil }
        return hip.point.y - knee.point.y
    }

    // NEW: Common helper for elbow angle on either side.
    private func armAngle(from joints: [String: BodyJoint], prefix: String) -> Float? {
        guard let wrist = joints["\(prefix)_wrist"],
              let elbow = joints["\(prefix)_elbow"],
              let shoulder = joints["\(prefix)_shoulder"] else { return nil }
        return calculateAngle(a: wrist.point, b: elbow.point, c: shoulder.point)
    }

    // NEW: Common helper for dead-hang wrist height.
    private func wristAboveShoulderLift(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let wrist = joints["\(prefix)_wrist"],
              let shoulder = joints["\(prefix)_shoulder"] else { return nil }
        return shoulder.point.y - wrist.point.y
    }

    // NEW: Common helper for overhead wrist height.
    private func wristAboveHeadLift(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let wrist = joints["\(prefix)_wrist"],
              let nose = joints["nose"] else { return nil }
        return nose.point.y - wrist.point.y
    }

    // NEW: Common helper for high-plank wrist stacking.
    private func shoulderWristHorizontalOffset(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let shoulder = joints["\(prefix)_shoulder"],
              let wrist = joints["\(prefix)_wrist"] else { return nil }
        return abs(shoulder.point.x - wrist.point.x)
    }

    // NEW: Common helper for forearm-plank elbow stacking.
    private func shoulderElbowHorizontalOffset(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let shoulder = joints["\(prefix)_shoulder"],
              let elbow = joints["\(prefix)_elbow"] else { return nil }
        return abs(shoulder.point.x - elbow.point.x)
    }

    // NEW: Common helper for forearm elbow angle.
    private func forearmElbowAngle(from joints: [String: BodyJoint], prefix: String) -> Float? {
        guard let wrist = joints["\(prefix)_wrist"],
              let elbow = joints["\(prefix)_elbow"],
              let shoulder = joints["\(prefix)_shoulder"] else { return nil }
        return calculateAngle(a: wrist.point, b: elbow.point, c: shoulder.point)
    }

    // NEW: Common helper for bridge hip lift.
    private func bridgeLift(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let hip = joints["\(prefix)_hip"],
              let knee = joints["\(prefix)_knee"] else { return nil }
        return knee.point.y - hip.point.y
    }

    // NEW: Common helper for bridge torso angle.
    private func bridgeAngle(from joints: [String: BodyJoint], prefix: String) -> Float? {
        guard let shoulder = joints["\(prefix)_shoulder"],
              let hip = joints["\(prefix)_hip"],
              let knee = joints["\(prefix)_knee"] else { return nil }
        return calculateAngle(a: shoulder.point, b: hip.point, c: knee.point)
    }

    // NEW: Common helper for side-plank body-line deviation.
    private func sidePlankLineDeviation(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let shoulder = joints["\(prefix)_shoulder"],
              let hip = joints["\(prefix)_hip"],
              let ankle = joints["\(prefix)_ankle"] else { return nil }
        return abs(shoulder.point.x - hip.point.x) + abs(hip.point.x - ankle.point.x)
    }

    // NEW: Common helper for side-plank hip sag.
    private func sidePlankHipSag(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let shoulder = joints["\(prefix)_shoulder"],
              let hip = joints["\(prefix)_hip"],
              let ankle = joints["\(prefix)_ankle"] else { return nil }
        let expectedHipY = (shoulder.point.y + ankle.point.y) / 2
        return max(0, hip.point.y - expectedHipY)
    }

    // NEW: Common helper for knee angle on either side.
    private func kneeAngle(from joints: [String: BodyJoint], prefix: String) -> Float? {
        guard let hip = joints["\(prefix)_hip"],
              let knee = joints["\(prefix)_knee"],
              let ankle = joints["\(prefix)_ankle"] else { return nil }
        return calculateAngle(a: hip.point, b: knee.point, c: ankle.point)
    }

    // NEW: Collect both legs as lunge candidates so the app can score either lead leg.
    private func lungeCandidates(from joints: [String: BodyJoint]) -> [(side: String, kneeAngle: Float)] {
        ["right", "left"].compactMap { side in
            guard let angle = kneeAngle(from: joints, prefix: side) else { return nil }
            return (side: side, kneeAngle: angle)
        }
    }

    // NEW: Collect both legs as hip-abduction candidates so the lifted leg can be whichever one is farther from midline.
    private func hipAbductionCandidates(from joints: [String: BodyJoint]) -> [(side: String, separation: Float)] {
        ["right", "left"].compactMap { side in
            let kneeKey = "\(side)_knee"
            let hipKey = "\(side)_hip"
            guard let knee = joints[kneeKey], let hip = joints[hipKey] else { return nil }
            return (side: side, separation: Float(abs(knee.point.x - hip.point.x)))
        }
    }

    // NEW: Common helper for the standing leg in hip abduction.
    private func standingLegAngle(from joints: [String: BodyJoint], prefix: String) -> Float? {
        kneeAngle(from: joints, prefix: prefix)
    }

    // NEW: Common helper for L-sit leg sag.
    private func lsitLegSag(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let hip = joints["\(prefix)_hip"],
              let knee = joints["\(prefix)_knee"] else { return nil }
        return abs(knee.point.y - hip.point.y)
    }

    // NEW: Common helper for arm or leg elevation relative to the hip.
    private func limbElevation(from joints: [String: BodyJoint], anchorPrefix: String, limb: String) -> CGFloat? {
        guard let hip = joints["\(anchorPrefix)_hip"],
              let endJoint = joints["\(anchorPrefix)_\(limb)"] else { return nil }
        return hip.point.y - endJoint.point.y
    }

    // NEW: Common helper for chest lift relative to the hip.
    private func chestLift(from joints: [String: BodyJoint], prefix: String) -> CGFloat? {
        guard let hip = joints["\(prefix)_hip"],
              let shoulder = joints["\(prefix)_shoulder"] else { return nil }
        return hip.point.y - shoulder.point.y
    }

    // NEW: Compact away missing optional measurements.
    private func compactMeasurements<T>(_ values: [T?]) -> [T] {
        values.compactMap { $0 }
    }

    // NEW: Average optional CGFloat measurements.
    private func averageCGFloat(_ values: [CGFloat]) -> CGFloat? {
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / CGFloat(values.count)
    }

    // NEW: Keep a non-optional exercise name for fallback analysis output before or outside successful ruleset lookup.
    private var currentExerciseName: String {
        guard !exerciseRules.isEmpty,
              currentExerciseId > 0,
              currentExerciseId <= exerciseRules.count else {
            return "Exercise"
        }
        return exerciseRules[currentExerciseId - 1].name
    }

    // NEW: Define how many posture checks each exercise can fail before form should bottom out.
    private func expectedCheckCount(for exerciseId: Int) -> Int {
        switch exerciseId {
        case 1: return 3
        case 2: return 2
        case 3: return 3
        case 4: return 2
        case 5: return 3
        case 6: return 2
        case 7: return 3
        case 8: return 4
        case 9: return 2
        case 10: return 3
        case 11: return 3
        case 12: return 3
        case 13: return 3
        case 14: return 3
        default: return 3
        }
    }

    // NEW: Blend pose-coverage confidence with failed-check ratio so form accuracy no longer sticks at 0% while points are being detected.
    private func confidenceScore(for exerciseId: Int, flags: [String], detectedJointCount: Int) -> Float {
        let totalChecks = max(expectedCheckCount(for: exerciseId), 1)
        let issueRatio = min(Double(flags.count) / Double(totalChecks), 1.0)
        let ruleScore = max(0.0, 1.0 - issueRatio)
        let poseCoverageScore = min(Double(detectedJointCount) / Double(jointMapping.count), 1.0)

        // Weight correctness more than raw joint coverage, while still rewarding a stable tracked pose.
        let blendedScore = (ruleScore * 0.8) + (poseCoverageScore * 0.2)
        return Float(blendedScore)
    }

    // NEW: Turn angle/range closeness into a live score so percentage reflects how close the pose is to the target, not just pass/fail flags.
    private func continuousConfidenceScore(
        for exerciseId: Int,
        joints: [String: BodyJoint],
        angles: [String: Float],
        flags: [String]
    ) -> Float {
        let poseCoverageScore = min(Double(joints.count) / Double(jointMapping.count), 1.0)
        let geometryScore: Double

        switch exerciseId {
        case 1:
            geometryScore = averageScore([
                scoreTarget(angles["body_alignment"], target: 180, tolerance: 18),
                scoreMax(delta(joints["right_hip"]?.point.y, joints["right_shoulder"]?.point.y), maxValue: 0.08, softTolerance: 0.08),
                scoreMin(armAngle(from: joints), minValue: 155, softTolerance: 20)
            ])
        case 2:
            let kneeAverage = averageOptional([angles["right_knee"], angles["left_knee"]])
            geometryScore = averageScore([
                scoreTarget(kneeAverage, target: 90, tolerance: 12),
                scoreMax(horizontalDistance(joints["right_shoulder"], joints["right_hip"]), maxValue: 0.08, softTolerance: 0.08)
            ])
        case 3:
            let kneeAverage = averageOptional([angles["right_knee"], angles["left_knee"]])
            geometryScore = averageScore([
                scoreTarget(kneeAverage, target: 90, tolerance: 18),
                scoreMax(horizontalDistance(joints["right_shoulder"], joints["right_hip"]), maxValue: 0.12, softTolerance: 0.10),
                scoreMin(depthDelta(joints["right_hip"], joints["right_knee"]), minValue: -0.05, softTolerance: 0.10)
            ])
        case 4:
            geometryScore = averageScore([
                scoreMin(bridgeLiftDelta(joints["right_knee"], joints["right_hip"]), minValue: 0.02, softTolerance: 0.12),
                scoreMin(angles["hip_angle"], minValue: 150, softTolerance: 20)
            ])
        case 5:
            geometryScore = averageScore([
                scoreMin(angles["right_arm"], minValue: 160, softTolerance: 20),
                scoreMin(angles["left_arm"], minValue: 160, softTolerance: 20),
                scoreMax(delta(joints["right_wrist"]?.point.y, joints["right_shoulder"]?.point.y), maxValue: 0.0, softTolerance: 0.10)
            ])
        case 6:
            geometryScore = averageScore([
                scoreMin(angles["right_arm"], minValue: 160, softTolerance: 20),
                scoreMin(angles["left_arm"], minValue: 160, softTolerance: 20),
                scoreMax(delta(joints["right_wrist"]?.point.y, joints["nose"]?.point.y), maxValue: 0.05, softTolerance: 0.10)
            ])
        case 7:
            geometryScore = averageScore([
                scoreTarget(angles["body_alignment"], target: 180, tolerance: 18),
                scoreMax(delta(joints["right_hip"]?.point.y, joints["right_shoulder"]?.point.y), maxValue: 0.08, softTolerance: 0.08),
                scoreMin(armAngle(from: joints), minValue: 155, softTolerance: 20)
            ])
        case 8:
            geometryScore = averageScore([
                scoreTarget(angles["body_alignment"], target: 180, tolerance: 18),
                scoreMax(delta(joints["right_hip"]?.point.y, joints["right_shoulder"]?.point.y), maxValue: 0.08, softTolerance: 0.08),
                scoreTarget(angles["elbow_angle"], target: 90, tolerance: 18),
                scoreMax(horizontalDistance(joints["right_shoulder"], joints["right_elbow"]), maxValue: 0.08, softTolerance: 0.08)
            ])
        case 9:
            geometryScore = averageScore([
                scoreMax(sidePlankLineDeviation(joints), maxValue: 0.15, softTolerance: 0.12),
                scoreMax(sidePlankHipSag(joints), maxValue: 0.08, softTolerance: 0.08)
            ])
        case 10:
            geometryScore = averageScore([
                scoreTarget(angles["front_knee"], target: 90, tolerance: 12),
                scoreMin(joints["left_knee"]?.point.y, minValue: 0.75, softTolerance: 0.15),
                scoreMax(horizontalDistance(joints["right_shoulder"], joints["right_hip"]), maxValue: 0.10, softTolerance: 0.08)
            ])
        case 11:
            geometryScore = averageScore([
                scoreMin(angles["leg_separation"], minValue: 0.12, softTolerance: 0.10),
                scoreMax(hipLevelDifference(joints), maxValue: 0.06, softTolerance: 0.06),
                scoreMin(standingLegAngle(joints), minValue: 160, softTolerance: 20)
            ])
        case 12:
            geometryScore = averageScore([
                scoreTarget(angles["hip_angle"], target: 90, tolerance: 18),
                scoreMax(lsitLegSag(joints), maxValue: 0.10, softTolerance: 0.10),
                scoreMin(armAngle(from: joints), minValue: 155, softTolerance: 20)
            ])
        case 13:
            geometryScore = averageScore([
                scoreTarget(angles["back_angle"], target: 180, tolerance: 18),
                scoreMax(delta(joints["right_ankle"]?.point.y, joints["right_hip"]?.point.y), maxValue: 0.05, softTolerance: 0.12),
                scoreMax(delta(joints["right_wrist"]?.point.y, joints["right_shoulder"]?.point.y), maxValue: 0.0, softTolerance: 0.12)
            ])
        case 14:
            geometryScore = averageScore([
                scoreMin(angles["arm_elevation"], minValue: 0.05, softTolerance: 0.10),
                scoreMin(angles["leg_elevation"], minValue: 0.05, softTolerance: 0.10),
                scoreMax(joints["right_shoulder"]?.point.y, maxValue: 0.45, softTolerance: 0.12)
            ])
        default:
            geometryScore = 0.0
        }

//        let flagPenalty = min(Double(flags.count) * 0.06, 0.24)
//        let blendedScore = max(0.0, ((geometryScore * 0.85) + (poseCoverageScore * 0.15)) - flagPenalty)
        // NEW: Use a softer blend so live tracking still yields a meaningful percentage while ruleset violations pull the score down instead of flattening it to zero.
        let ruleScore = max(0.0, 1.0 - (Double(flags.count) / Double(max(expectedCheckCount(for: exerciseId), 1) + 1)))
        let jointConfidenceScore = averageJointConfidence(from: joints)
        let blendedScore = min(
            max(
                (geometryScore * 0.45) +
                (ruleScore * 0.30) +
                (poseCoverageScore * 0.15) +
                (jointConfidenceScore * 0.10),
                joints.isEmpty ? 0.0 : 0.18
            ),
            0.99
        )
        return Float(blendedScore)
    }

    // NEW: Average only the checks that are actually available from the current detected pose.
    private func averageScore(_ values: [Double?]) -> Double {
        let present = values.compactMap { $0 }
        guard !present.isEmpty else { return 0.0 }
        return present.reduce(0.0, +) / Double(present.count)
    }

    // NEW: Use detected joint confidence from Vision so the form score reflects whether the model is actually seeing the body clearly.
    private func averageJointConfidence(from joints: [String: BodyJoint]) -> Double {
        guard !joints.isEmpty else { return 0.0 }
        let total = joints.values.reduce(0.0) { partialResult, joint in
            partialResult + Double(joint.confidence)
        }
        return total / Double(joints.count)
    }

    // NEW: Average optional Float measurements into one Float target input.
    private func averageOptional(_ values: [Float?]) -> Float? {
        let present = values.compactMap { $0 }
        guard !present.isEmpty else { return nil }
        return present.reduce(0, +) / Float(present.count)
    }

    // NEW: Score closeness to a target angle/value.
    private func scoreTarget(_ value: Float?, target: Float, tolerance: Float) -> Double? {
        guard let value else { return nil }
        let normalizedError = min(abs(value - target) / tolerance, 1)
        return Double(1 - normalizedError)
    }

    // NEW: Score values that should stay below a threshold.
    private func scoreMax(_ value: CGFloat?, maxValue: CGFloat, softTolerance: CGFloat) -> Double? {
        guard let value else { return nil }
        if value <= maxValue { return 1.0 }
        let overflow = min((value - maxValue) / softTolerance, 1)
        return Double(1 - overflow)
    }

    // NEW: Score values that should stay above a threshold.
    private func scoreMin(_ value: CGFloat?, minValue: CGFloat, softTolerance: CGFloat) -> Double? {
        guard let value else { return nil }
        if value >= minValue { return 1.0 }
        let underflow = min((minValue - value) / softTolerance, 1)
        return Double(1 - underflow)
    }

    // NEW: Overload scoreMin for angle values carried as Float.
    private func scoreMin(_ value: Float?, minValue: Float, softTolerance: Float) -> Double? {
        guard let value else { return nil }
        if value >= minValue { return 1.0 }
        let underflow = min((minValue - value) / softTolerance, 1)
        return Double(1 - underflow)
    }

    // NEW: Safe difference helper for optional CGFloat measurements.
    private func delta(_ first: CGFloat?, _ second: CGFloat?) -> CGFloat? {
        guard let first, let second else { return nil }
        return first - second
    }

    // NEW: Horizontal alignment helper used by stacked-joint checks.
    private func horizontalDistance(_ first: BodyJoint?, _ second: BodyJoint?) -> CGFloat? {
        guard let first, let second else { return nil }
        return abs(first.point.x - second.point.x)
    }

    // NEW: Single-side arm angle helper for exercises that just need a straight-arm score.
    private func armAngle(from joints: [String: BodyJoint]) -> Float? {
        guard let wrist = joints["right_wrist"],
              let elbow = joints["right_elbow"],
              let shoulder = joints["right_shoulder"] else { return nil }
        return calculateAngle(a: wrist.point, b: elbow.point, c: shoulder.point)
    }

    // NEW: Positive value means hips are lifted above knees in a bridge.
    private func bridgeLiftDelta(_ knee: BodyJoint?, _ hip: BodyJoint?) -> CGFloat? {
        guard let knee, let hip else { return nil }
        return knee.point.y - hip.point.y
    }

    // NEW: Positive value means hips are low enough relative to knees in a squat.
    private func depthDelta(_ hip: BodyJoint?, _ knee: BodyJoint?) -> CGFloat? {
        guard let hip, let knee else { return nil }
        return hip.point.y - knee.point.y
    }

    // NEW: Measures how far shoulder, hip, and ankle drift out of a straight stacked line in side plank.
    private func sidePlankLineDeviation(_ joints: [String: BodyJoint]) -> CGFloat? {
        guard let shoulder = joints["right_shoulder"],
              let hip = joints["right_hip"],
              let ankle = joints["right_ankle"] else { return nil }
        return abs(shoulder.point.x - hip.point.x) + abs(hip.point.x - ankle.point.x)
    }

    // NEW: Measures how far the hip drops below the shoulder-ankle midpoint in side plank.
    private func sidePlankHipSag(_ joints: [String: BodyJoint]) -> CGFloat? {
        guard let shoulder = joints["right_shoulder"],
              let hip = joints["right_hip"],
              let ankle = joints["right_ankle"] else { return nil }
        let expectedHipY = (shoulder.point.y + ankle.point.y) / 2
        return max(0, hip.point.y - expectedHipY)
    }

    // NEW: Measures left/right hip height mismatch for standing balance checks.
    private func hipLevelDifference(_ joints: [String: BodyJoint]) -> CGFloat? {
        guard let rightHip = joints["right_hip"],
              let leftHip = joints["left_hip"] else { return nil }
        return abs(rightHip.point.y - leftHip.point.y)
    }

    // NEW: Angle score for the standing support leg in hip abduction.
    private func standingLegAngle(_ joints: [String: BodyJoint]) -> Float? {
        guard let hip = joints["left_hip"],
              let knee = joints["left_knee"],
              let ankle = joints["left_ankle"] else { return nil }
        return calculateAngle(a: hip.point, b: knee.point, c: ankle.point)
    }

    // NEW: Measures how far the L-sit legs drop away from hip height.
    private func lsitLegSag(_ joints: [String: BodyJoint]) -> CGFloat? {
        guard let hip = joints["right_hip"],
              let knee = joints["right_knee"] else { return nil }
        return abs(knee.point.y - hip.point.y)
    }

    // MARK: - Validation Functions

    // ── 1. Plank ─────────────────────────────────────────────────────────────
    private func validatePlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let shoulder = joints["right_shoulder"],
              let hip      = joints["right_hip"],
              let ankle    = joints["right_ankle"] else {
            return ["Cannot detect shoulders, hips, or ankles"]
        }
        // Body should be nearly horizontal (Y values similar)
        let bodyAngle = calculateAngle(a: shoulder.point, b: hip.point, c: ankle.point)
        if abs(bodyAngle - 180) > 15 {
            flags.append(exercise.flags["misaligned_body"] ?? "Body not straight")
        }
        // Hips must not sag below shoulder line
        if hip.point.y > shoulder.point.y + 0.08 {
            flags.append(exercise.flags["sagging_hips"] ?? "Hips sagging")
        }
        // Arm check
        if let elbow = joints["right_elbow"], let wrist = joints["right_wrist"] {
            let armAngle = calculateAngle(a: wrist.point, b: elbow.point, c: shoulder.point)
            if armAngle < 155 {
                flags.append(exercise.flags["bent_elbows"] ?? "Elbows bent — keep arms straight")
            }
        }
        return flags
    }

    // ── 2. Wall Sit ──────────────────────────────────────────────────────────
    private func validateWallSit(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let rKnee  = joints["right_knee"],
              let rAnkle = joints["right_ankle"],
              let rHip   = joints["right_hip"] else {
            return ["Cannot detect hip, knee, or ankle"]
        }
        // Knee angle
        let rAngle = calculateAngle(a: rHip.point, b: rKnee.point, c: rAnkle.point)
        if let lKnee = joints["left_knee"], let lAnkle = joints["left_ankle"], let lHip = joints["left_hip"] {
            let lAngle = calculateAngle(a: lHip.point, b: lKnee.point, c: lAnkle.point)
            let avg = (rAngle + lAngle) / 2
            if avg < 80 || avg > 100 {
                flags.append(exercise.flags["knee_angle_incorrect"] ?? "Knee angle incorrect — target 85–95°")
            }
        } else {
            if rAngle < 80 || rAngle > 100 {
                flags.append(exercise.flags["knee_angle_incorrect"] ?? "Knee angle incorrect — target 85–95°")
            }
        }
        // Back vertical: shoulder X ≈ hip X
        if let shoulder = joints["right_shoulder"] {
            if abs(shoulder.point.x - rHip.point.x) > 0.08 {
                flags.append(exercise.flags["back_tilted"] ?? "Back not vertical — keep against wall")
            }
        }
        return flags
    }

    // ── 3. Static Squat ──────────────────────────────────────────────────────
    private func validateStaticSquat(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let rKnee  = joints["right_knee"],
              let rHip   = joints["right_hip"],
              let rAnkle = joints["right_ankle"] else {
            return ["Cannot detect hip, knee, or ankle"]
        }
        let rAngle = calculateAngle(a: rHip.point, b: rKnee.point, c: rAnkle.point)
        if rAngle < 75 || rAngle > 110 {
            flags.append(exercise.flags["knee_angle_incorrect"] ?? "Knee angle out of range — target 80–100°")
        }
        if let lKnee = joints["left_knee"], let lHip = joints["left_hip"], let lAnkle = joints["left_ankle"] {
            let lAngle = calculateAngle(a: lHip.point, b: lKnee.point, c: lAnkle.point)
            if lAngle < 75 || lAngle > 110 {
                flags.append("Left knee angle incorrect")
            }
        }
        // Hips below knee level (Y greater = lower in screen)
        if rHip.point.y < rKnee.point.y - 0.05 {
            flags.append(exercise.flags["hips_too_high"] ?? "Hips too high — squat deeper")
        }
        // Torso upright: shoulder X ≈ hip X
        if let shoulder = joints["right_shoulder"] {
            if abs(shoulder.point.x - rHip.point.x) > 0.12 {
                flags.append(exercise.flags["torso_tilted"] ?? "Torso tilted — keep upright")
            }
        }
        return flags
    }

    // ── 4. Glute Bridge ──────────────────────────────────────────────────────
    private func validateGlueBridge(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let rHip      = joints["right_hip"],
              let rKnee     = joints["right_knee"],
              let rShoulder = joints["right_shoulder"] else {
            return ["Cannot detect required joints"]
        }
        // Hip must be elevated above knee level (lower Y = higher on screen)
        if rHip.point.y >= rKnee.point.y {
            flags.append(exercise.flags["hips_not_elevated"] ?? "Hips not elevated — push through heels")
        }
        // Shoulder–hip–knee angle > 150°
        let angle = calculateAngle(a: rShoulder.point, b: rHip.point, c: rKnee.point)
        if angle < 150 {
            flags.append(exercise.flags["hips_sagging"] ?? "Hips sagging — squeeze glutes")
        }
        return flags
    }

    // ── 5. Dead Hang ─────────────────────────────────────────────────────────
    private func validateDeadHang(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let rWrist    = joints["right_wrist"],
              let rElbow    = joints["right_elbow"],
              let rShoulder = joints["right_shoulder"],
              let lWrist    = joints["left_wrist"],
              let lElbow    = joints["left_elbow"],
              let lShoulder = joints["left_shoulder"] else {
            return ["Cannot detect arms"]
        }
        let rAngle = calculateAngle(a: rWrist.point, b: rElbow.point, c: rShoulder.point)
        let lAngle = calculateAngle(a: lWrist.point, b: lElbow.point, c: lShoulder.point)
        if rAngle < 155 { flags.append(exercise.flags["elbows_bent"] ?? "Right elbow bent") }
        if lAngle < 155 { flags.append(exercise.flags["elbows_bent"] ?? "Left elbow bent") }
        // Wrists above shoulders (lower Y = higher)
        if rWrist.point.y > rShoulder.point.y {
            flags.append(exercise.flags["wrists_below_shoulders"] ?? "Wrists not above shoulders")
        }
        return flags
    }

    // ── 6. Overhead Hold ─────────────────────────────────────────────────────
    private func validateOverheadHold(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let rWrist    = joints["right_wrist"],
              let rElbow    = joints["right_elbow"],
              let rShoulder = joints["right_shoulder"],
              let lWrist    = joints["left_wrist"],
              let lElbow    = joints["left_elbow"],
              let lShoulder = joints["left_shoulder"] else {
            return ["Cannot detect arms"]
        }
        let rAngle = calculateAngle(a: rWrist.point, b: rElbow.point, c: rShoulder.point)
        let lAngle = calculateAngle(a: lWrist.point, b: lElbow.point, c: lShoulder.point)
        if rAngle < 155 || lAngle < 155 {
            flags.append(exercise.flags["elbows_bent"] ?? "Arms not straight — straighten > 160°")
        }
        if let nose = joints["nose"] {
            // Wrists should be above nose level
            if rWrist.point.y > nose.point.y + 0.05 {
                flags.append(exercise.flags["wrists_forward"] ?? "Wrists not overhead — stack above shoulders")
            }
        }
        return flags
    }

    // ── 7. High Plank ────────────────────────────────────────────────────────
    private func validateHighPlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let shoulder = joints["right_shoulder"],
              let hip      = joints["right_hip"],
              let ankle    = joints["right_ankle"] else {
            return ["Cannot detect required joints"]
        }
        let bodyAngle = calculateAngle(a: shoulder.point, b: hip.point, c: ankle.point)
        if abs(bodyAngle - 180) > 15 {
            flags.append(exercise.flags["body_misaligned"] ?? "Body not straight")
        }
        if hip.point.y > shoulder.point.y + 0.08 {
            flags.append(exercise.flags["hips_sagging"] ?? "Hips sagging")
        }
        if let elbow = joints["right_elbow"], let wrist = joints["right_wrist"] {
            let armAngle = calculateAngle(a: wrist.point, b: elbow.point, c: shoulder.point)
            if armAngle < 155 {
                flags.append(exercise.flags["elbows_bent"] ?? "Elbows bent — lock arms")
            }
        }
        return flags
    }

    // ── 8. Low Plank (Forearm) ───────────────────────────────────────────────
    private func validateLowPlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let shoulder = joints["right_shoulder"],
              let elbow    = joints["right_elbow"],
              let hip      = joints["right_hip"],
              let ankle    = joints["right_ankle"] else {
            return ["Cannot detect required joints"]
        }
        // Body alignment
        let bodyAngle = calculateAngle(a: shoulder.point, b: hip.point, c: ankle.point)
        if abs(bodyAngle - 180) > 15 {
            flags.append(exercise.flags["body_misaligned"] ?? "Body not straight")
        }
        // Hip sag
        if hip.point.y > shoulder.point.y + 0.08 {
            flags.append(exercise.flags["hips_sagging"] ?? "Hips sagging")
        }
        // Elbow ~90°
        if let wrist = joints["right_wrist"] {
            let elbowAngle = calculateAngle(a: wrist.point, b: elbow.point, c: shoulder.point)
            if elbowAngle < 75 || elbowAngle > 105 {
                flags.append(exercise.flags["elbows_not_90"] ?? "Elbow angle incorrect — target ~90°")
            }
        }
        // Shoulder over elbow
        if abs(shoulder.point.x - elbow.point.x) > 0.08 {
            flags.append(exercise.flags["shoulder_not_stacked"] ?? "Shoulder not over elbow")
        }
        return flags
    }

    // ── 9. Side Plank ────────────────────────────────────────────────────────
    private func validateSidePlank(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let shoulder = joints["right_shoulder"],
              let hip      = joints["right_hip"],
              let ankle    = joints["right_ankle"] else {
            return ["Cannot detect required joints"]
        }
        // X alignment (all three should share similar X in side plank)
        let xDev = abs(shoulder.point.x - hip.point.x) + abs(hip.point.x - ankle.point.x)
        if xDev > 0.15 {
            flags.append(exercise.flags["not_straight_line"] ?? "Body not in straight line")
        }
        // Hip sag: hip Y should be between shoulder Y and ankle Y
        let expectedHipY = (shoulder.point.y + ankle.point.y) / 2
        if hip.point.y > expectedHipY + 0.08 {
            flags.append(exercise.flags["hip_sagging"] ?? "Hip sagging — engage obliques")
        }
        return flags
    }

    // ── 10. Lunge Hold ───────────────────────────────────────────────────────
    private func validateLungeHold(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let rKnee  = joints["right_knee"],
              let rHip   = joints["right_hip"],
              let rAnkle = joints["right_ankle"],
              let lKnee  = joints["left_knee"],
              let lHip   = joints["left_hip"],
              let lAnkle = joints["left_ankle"] else {
            return ["Cannot detect leg joints"]
        }
        let frontAngle = calculateAngle(a: rHip.point, b: rKnee.point, c: rAnkle.point)
        if frontAngle < 80 || frontAngle > 100 {
            flags.append(exercise.flags["front_knee_angle_incorrect"] ?? "Front knee angle incorrect — target 85–95°")
        }
        // Back knee should be close to ground (high Y value)
        if lKnee.point.y < 0.75 {
            flags.append(exercise.flags["back_knee_too_high"] ?? "Back knee too high — lower down")
        }
        // Torso upright
        if let shoulder = joints["right_shoulder"] {
            if abs(shoulder.point.x - rHip.point.x) > 0.10 {
                flags.append(exercise.flags["torso_tilted"] ?? "Torso tilted — keep upright")
            }
        }
        return flags
    }

    // ── 11. Hip Abduction Hold ───────────────────────────────────────────────
    private func validateHipAbduction(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let rHip  = joints["right_hip"],
              let lHip  = joints["left_hip"],
              let rKnee = joints["right_knee"] else {
            return ["Cannot detect hip/knee"]
        }
        // Lateral separation between raised knee and hip
        let separation = abs(rKnee.point.x - rHip.point.x)
        if separation < 0.12 {
            flags.append(exercise.flags["leg_not_raised_enough"] ?? "Leg not raised enough — lift > 20°")
        }
        // Hip level
        if abs(rHip.point.y - lHip.point.y) > 0.06 {
            flags.append(exercise.flags["hip_dropping"] ?? "Hip dropping — engage core")
        }
        // Standing leg straight
        if let lKnee = joints["left_knee"], let lAnkle = joints["left_ankle"] {
            let standAngle = calculateAngle(a: lHip.point, b: lKnee.point, c: lAnkle.point)
            if standAngle < 160 {
                flags.append(exercise.flags["standing_leg_bent"] ?? "Standing leg bent — keep straight")
            }
        }
        return flags
    }

    // ── 12. L-Sit ────────────────────────────────────────────────────────────
    private func validateLSit(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let rHip   = joints["right_hip"],
              let rKnee  = joints["right_knee"],
              let rAnkle = joints["right_ankle"] else {
            return ["Cannot detect leg joints"]
        }
        // Hip angle ~90°
        if let rShoulder = joints["right_shoulder"] {
            let hipAngle = calculateAngle(a: rShoulder.point, b: rHip.point, c: rKnee.point)
            if hipAngle < 75 || hipAngle > 105 {
                flags.append(exercise.flags["hip_angle_incorrect"] ?? "Hip angle incorrect — target 90°")
            }
        }
        // Legs horizontal (knee and ankle Y ≈ hip Y)
        let legsParallel = abs(rKnee.point.y - rHip.point.y)
        if legsParallel > 0.1 {
            flags.append(exercise.flags["legs_sagging"] ?? "Legs sagging — raise to parallel")
        }
        // Arms straight
        if let rElbow = joints["right_elbow"], let rWrist = joints["right_wrist"], let rShoulder = joints["right_shoulder"] {
            let armAngle = calculateAngle(a: rWrist.point, b: rElbow.point, c: rShoulder.point)
            if armAngle < 155 {
                flags.append(exercise.flags["elbows_bent"] ?? "Elbows bent — keep arms straight")
            }
        }
        return flags
    }

    // ── 13. Hollow Body ──────────────────────────────────────────────────────
    private func validateHollowBody(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let shoulder = joints["right_shoulder"],
              let hip      = joints["right_hip"],
              let knee     = joints["right_knee"],
              let ankle    = joints["right_ankle"] else {
            return ["Cannot detect body joints"]
        }
        // Lower back flat: shoulder–hip–knee should be close to 180°
        let backAngle = calculateAngle(a: shoulder.point, b: hip.point, c: knee.point)
        if abs(backAngle - 180) > 15 {
            flags.append(exercise.flags["lower_back_arched"] ?? "Lower back arching — flatten it")
        }
        // Legs raised (lower Y on screen = higher)
        if ankle.point.y > hip.point.y + 0.05 {
            flags.append(exercise.flags["legs_not_raised"] ?? "Legs not raised enough — target 30°")
        }
        // Arms overhead
        if let wrist = joints["right_wrist"] {
            if wrist.point.y > shoulder.point.y {
                flags.append(exercise.flags["arms_not_overhead"] ?? "Arms not overhead — extend up")
            }
        }
        return flags
    }

    // ── 14. Superman ─────────────────────────────────────────────────────────
    private func validateSuperman(exercise: ExerciseRule, joints: [String: BodyJoint]) -> [String] {
        var flags: [String] = []
        guard let shoulder = joints["right_shoulder"],
              let wrist    = joints["right_wrist"],
              let hip      = joints["right_hip"],
              let ankle    = joints["right_ankle"] else {
            return ["Cannot detect body joints"]
        }
        if wrist.point.y > hip.point.y - 0.05 {
            flags.append(exercise.flags["arms_not_elevated"] ?? "Arms not elevated — lift higher")
        }
        if ankle.point.y > hip.point.y - 0.05 {
            flags.append(exercise.flags["legs_not_elevated"] ?? "Legs not elevated — raise up")
        }
        if shoulder.point.y > 0.45 {
            flags.append(exercise.flags["chest_not_lifted"] ?? "Chest not lifted — engage back")
        }
        return flags
    }

    // MARK: - Angle Calculator

    private func calculateAngle(a: CGPoint, b: CGPoint, c: CGPoint) -> Float {
        let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let cb = CGPoint(x: b.x - c.x, y: b.y - c.y)
        let dot    = ab.x * cb.x + ab.y * cb.y
        let abMag  = sqrt(ab.x * ab.x + ab.y * ab.y)
        let cbMag  = sqrt(cb.x * cb.x + cb.y * cb.y)
        guard abMag > 0, cbMag > 0 else { return 0 }
        let cosA = min(max(Float(dot / (abMag * cbMag)), -1), 1)
        return acos(cosA) * 180 / .pi
    }

    // MARK: - Angle Extraction (for result reporting)

    private func calcPlankAngles(_ j: [String: BodyJoint]) -> [String: Float] {
        var a: [String: Float] = [:]
        if let s = j["right_shoulder"], let h = j["right_hip"], let k = j["right_ankle"] {
            a["body_alignment"] = calculateAngle(a: s.point, b: h.point, c: k.point)
        }
        return a
    }

    private func calcKneeAngles(_ j: [String: BodyJoint]) -> [String: Float] {
        var a: [String: Float] = [:]
        if let h = j["right_hip"], let k = j["right_knee"], let an = j["right_ankle"] {
            a["right_knee"] = calculateAngle(a: h.point, b: k.point, c: an.point)
        }
        if let h = j["left_hip"], let k = j["left_knee"], let an = j["left_ankle"] {
            a["left_knee"] = calculateAngle(a: h.point, b: k.point, c: an.point)
        }
        return a
    }

    private func calcHipAngles(_ j: [String: BodyJoint]) -> [String: Float] {
        var a: [String: Float] = [:]
        if let s = j["right_shoulder"], let h = j["right_hip"], let k = j["right_knee"] {
            a["hip_angle"] = calculateAngle(a: s.point, b: h.point, c: k.point)
        }
        return a
    }

    private func calcArmAngles(_ j: [String: BodyJoint]) -> [String: Float] {
        var a: [String: Float] = [:]
        if let w = j["right_wrist"], let e = j["right_elbow"], let s = j["right_shoulder"] {
            a["right_arm"] = calculateAngle(a: w.point, b: e.point, c: s.point)
        }
        if let w = j["left_wrist"], let e = j["left_elbow"], let s = j["left_shoulder"] {
            a["left_arm"] = calculateAngle(a: w.point, b: e.point, c: s.point)
        }
        return a
    }

    private func calcForearmPlankAngles(_ j: [String: BodyJoint]) -> [String: Float] {
        var a: [String: Float] = [:]
        if let s = j["right_shoulder"], let e = j["right_elbow"], let h = j["right_hip"] {
            a["elbow_angle"] = calculateAngle(a: s.point, b: e.point, c: h.point)
        }
        if let s = j["right_shoulder"], let h = j["right_hip"], let an = j["right_ankle"] {
            a["body_alignment"] = calculateAngle(a: s.point, b: h.point, c: an.point)
        }
        return a
    }

    private func calcLungeAngles(_ j: [String: BodyJoint]) -> [String: Float] {
        var a: [String: Float] = [:]
        if let h = j["right_hip"], let k = j["right_knee"], let an = j["right_ankle"] {
            a["front_knee"] = calculateAngle(a: h.point, b: k.point, c: an.point)
        }
        return a
    }

    private func calcHipAbductionAngles(_ j: [String: BodyJoint]) -> [String: Float] {
        var a: [String: Float] = [:]
        if let h = j["right_hip"], let k = j["right_knee"] {
            a["leg_separation"] = Float(abs(k.point.x - h.point.x))
        }
        return a
    }

    private func calcHollowBodyAngles(_ j: [String: BodyJoint]) -> [String: Float] {
        var a: [String: Float] = [:]
        if let s = j["right_shoulder"], let h = j["right_hip"], let k = j["right_knee"] {
            a["back_angle"] = calculateAngle(a: s.point, b: h.point, c: k.point)
        }
        return a
    }

    private func calcSupermanAngles(_ j: [String: BodyJoint]) -> [String: Float] {
        var a: [String: Float] = [:]
        if let h = j["right_hip"], let w = j["right_wrist"], let an = j["right_ankle"] {
            a["arm_elevation"] = Float(h.point.y - w.point.y)
            a["leg_elevation"] = Float(h.point.y - an.point.y)
        }
        return a
    }

    deinit { stopCameraSession() }
}
