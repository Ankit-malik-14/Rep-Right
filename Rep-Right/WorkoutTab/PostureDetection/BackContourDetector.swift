import SwiftUI
import AVFoundation
import Vision

enum CalibrationPhase {
    case infoSheet
    case detectingPerson
    case timer
    case analyzing
}

@Observable
class BackContourDetector: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private struct ContourAnalysisState {
        var analyzedFrameCount: Int = 0
        var correctFrameCount: Int = 0
        var feedbackCounts: [String: Int] = [:]
    }
    
    private struct ContourPoseSnapshot {
        var neck: CGPoint
        var root: CGPoint
        var minY: CGFloat
        var maxY: CGFloat
        var isFacingLeft: Bool
        var joints: [String: CGPoint]
    }

    private struct ContourSample {
        var point: CGPoint
        var progress: CGFloat
    }
    
    // Core AVFoundation
    let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "video.sessionQueue")
    private let processQueue = DispatchQueue(label: "video.processQueue")
    
    private var currentCameraPosition: AVCaptureDevice.Position = .front
    
    // State
    var phase: CalibrationPhase = .infoSheet
    var isBackStraight: Bool = true
    var contourPoints: [CGPoint] = []
    var detectionFeedback: String = ""
    var repCount: Int = 0
    var elapsedSeconds: Int = 0
    var elapsedFormatted: String = "00:00"
    var analyzedFrameCount: Int = 0
    var correctFrameCount: Int = 0
    var initialElapsedSeconds: Int = 0
    var currentExerciseName: String = "Bodyweight Squat"
    
    // Timer state
    var timerTime: Int = 3
    private var timer: Timer?
    private var elapsedTimer: Timer?
    private var isCountdownArmed: Bool = false

    // Rep counting state
    private let repCountingQueue = DispatchQueue(label: "video.repCountingQueue", qos: .userInitiated)
    private let jointRepCounter = JointRepCounter()
    private var analysisState = ContourAnalysisState()
    private var cachedContourPose: ContourPoseSnapshot?
    private var contourFrameIndex: Int = 0
    private let poseRefreshInterval = 1
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupSession()
                    self?.startSession()
                }
            }
        default:
            break
        }
    }
    
    func toggleCamera() {
        sessionQueue.async {
            self.currentCameraPosition = self.currentCameraPosition == .front ? .back : .front
            self.setupSession()
        }
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high
            
            // Remove existing inputs
            for input in self.captureSession.inputs {
                self.captureSession.removeInput(input)
            }
            
            // Add new input
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: self.currentCameraPosition),
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                self.captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    self.detectionFeedback = "Camera not available (Simulator?)"
                }
                return
            }
            
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }
            
            if !self.captureSession.outputs.contains(self.videoDataOutput) {
                self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
                self.videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
                self.videoDataOutput.setSampleBufferDelegate(self, queue: self.processQueue)
                
                if self.captureSession.canAddOutput(self.videoDataOutput) {
                    self.captureSession.addOutput(self.videoDataOutput)
                }
                
                // Adjust connection rotation if needed
                if let connection = self.videoDataOutput.connection(with: .video) {
                    connection.videoRotationAngle = 90 // Default Portrait
                    connection.isVideoMirrored = (self.currentCameraPosition == .front)
                }
            } else {
                // Update connection mirroring for existing output
                if let connection = self.videoDataOutput.connection(with: .video) {
                    connection.isVideoMirrored = (self.currentCameraPosition == .front)
                }
            }
            
            self.captureSession.commitConfiguration()
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
        stopElapsedTimer()
        isCountdownArmed = false
    }
    
    func startDetectingPerson() {
        DispatchQueue.main.async {
            self.isCountdownArmed = false
            self.phase = .detectingPerson
            if self.detectionFeedback == "" || self.detectionFeedback == "Analyzing..." {
                self.detectionFeedback = "Please stand sideways in the frame"
            }
        }
    }
    
    func startTimer() {
        DispatchQueue.main.async {
            guard self.phase == .detectingPerson, !self.isCountdownArmed else { return }
            self.isCountdownArmed = true
            self.phase = .timer
            self.timerTime = 3
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.timerTime > 1 {
                    self.timerTime -= 1
                } else {
                    self.timer?.invalidate()
                    self.beginAnalyzingPhase()
                }
            }
        }
    }
    
    func beginAnalyzingPhase() {
        isCountdownArmed = false
        resetSetMetrics()
        phase = .analyzing
        detectionFeedback = "Analyzing..."
        startElapsedTimer()
    }
    
    func finishSet() {
        timer?.invalidate()
        stopElapsedTimer()
        isCountdownArmed = false
        phase = .infoSheet
    }
    
    private func resetSetMetrics() {
        let exerciseName = currentExerciseName
        repCount = 0
        elapsedSeconds = initialElapsedSeconds
        elapsedFormatted = Self.formatElapsedTime(initialElapsedSeconds)
        analyzedFrameCount = 0
        correctFrameCount = 0
        analysisState = ContourAnalysisState()
        repCountingQueue.async { [weak self] in
            guard let self else { return }
            self.jointRepCounter.configure(exerciseName: exerciseName)
        }
    }
    
    private func startElapsedTimer() {
        elapsedSeconds = initialElapsedSeconds
        elapsedFormatted = Self.formatElapsedTime(initialElapsedSeconds)
        elapsedTimer?.invalidate()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            self.elapsedFormatted = Self.formatElapsedTime(self.elapsedSeconds)
        }
    }
    
    private func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }
    
    private func makeContourPoseSnapshot(from observation: VNHumanBodyPoseObservation) -> ContourPoseSnapshot? {
        let allJoints: [VNHumanBodyPoseObservation.JointName] = [
            .nose, .neck, .rightShoulder, .leftShoulder, .rightElbow, .leftElbow,
            .rightWrist, .leftWrist, .rightHip, .leftHip, .rightKnee, .leftKnee,
            .rightAnkle, .leftAnkle
        ]

        var joints: [String: CGPoint] = [:]

        func addJoint(_ visionJoint: VNHumanBodyPoseObservation.JointName, name: String, point: VNRecognizedPoint) {
            let normalized = CGPoint(x: point.location.x, y: 1.0 - point.location.y)
            joints[name] = normalized
        }

        for visionJoint in allJoints {
            guard let pt = try? observation.recognizedPoint(visionJoint), pt.confidence > 0.3 else { continue }
            switch visionJoint {
            case .nose: addJoint(visionJoint, name: "nose", point: pt)
            case .neck: addJoint(visionJoint, name: "neck", point: pt)
            case .rightShoulder: addJoint(visionJoint, name: "right_shoulder", point: pt)
            case .leftShoulder: addJoint(visionJoint, name: "left_shoulder", point: pt)
            case .rightElbow: addJoint(visionJoint, name: "right_elbow", point: pt)
            case .leftElbow: addJoint(visionJoint, name: "left_elbow", point: pt)
            case .rightWrist: addJoint(visionJoint, name: "right_wrist", point: pt)
            case .leftWrist: addJoint(visionJoint, name: "left_wrist", point: pt)
            case .rightHip: addJoint(visionJoint, name: "right_hip", point: pt)
            case .leftHip: addJoint(visionJoint, name: "left_hip", point: pt)
            case .rightKnee: addJoint(visionJoint, name: "right_knee", point: pt)
            case .leftKnee: addJoint(visionJoint, name: "left_knee", point: pt)
            case .rightAnkle: addJoint(visionJoint, name: "right_ankle", point: pt)
            case .leftAnkle: addJoint(visionJoint, name: "left_ankle", point: pt)
            default:
                break
            }
        }

        guard let neckPoint = try? observation.recognizedPoint(.neck),
              neckPoint.confidence > 0.3,
              let rootPoint = try? observation.recognizedPoint(.root),
              rootPoint.confidence > 0.3 else {
            return nil
        }
        
        let neck = CGPoint(x: neckPoint.location.x, y: 1.0 - neckPoint.location.y)
        let root = CGPoint(x: rootPoint.location.x, y: 1.0 - rootPoint.location.y)
        var minY = neck.y
        var maxY = root.y
        
        if minY > maxY {
            swap(&minY, &maxY)
        }
        
        var isFacingLeft = true
        if let nose = try? observation.recognizedPoint(.nose),
           let rightEar = try? observation.recognizedPoint(.rightEar),
           let leftEar = try? observation.recognizedPoint(.leftEar) {
            let ear = rightEar.confidence > leftEar.confidence ? rightEar : leftEar
            if nose.confidence > 0.1 && ear.confidence > 0.1 {
                isFacingLeft = nose.location.x < ear.location.x
            }
        }
        
        return ContourPoseSnapshot(
            neck: neck,
            root: root,
            minY: minY,
            maxY: maxY,
            isFacingLeft: isFacingLeft,
            joints: joints
        )
    }

    func configureExercise(name: String) {
        currentExerciseName = name
        let configuredName = name
        repCountingQueue.async { [weak self] in
            guard let self else { return }
            self.jointRepCounter.configure(exerciseName: configuredName)
        }
    }

    private func currentRepStyle() -> ContourRepCounter.ExerciseStyle {
        let normalized = currentExerciseName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized.contains("squat") || normalized.contains("lunge") || normalized.contains("deadlift") {
            return .squatLike
        }
        if normalized.contains("row") || normalized.contains("pull") {
            return .rowLike
        }
        return .generic
    }

    private func makeContourRepMeasurement(
        from samples: [ContourSample],
        poseSnapshot: ContourPoseSnapshot,
        style: ContourRepCounter.ExerciseStyle
    ) -> ContourRepMeasurement? {
        let contour = contourMotion(from: samples, poseSnapshot: poseSnapshot, style: style)
        let joint = jointMotion(from: poseSnapshot, style: style)

        guard contour.motion != nil || joint.motion != nil else { return nil }
        return ContourRepMeasurement(
            contourMotion: contour.motion,
            contourConfidence: contour.confidence,
            jointMotion: joint.motion,
            jointConfidence: joint.confidence
        )
    }

    private func contourMotion(
        from samples: [ContourSample],
        poseSnapshot: ContourPoseSnapshot,
        style: ContourRepCounter.ExerciseStyle
    ) -> (motion: Double?, confidence: Double) {
        guard !samples.isEmpty else { return (nil, 0) }

        let targetRange: ClosedRange<CGFloat>
        switch style {
        case .squatLike:
            targetRange = 0.55...1.0
        case .rowLike:
            targetRange = 0.12...0.65
        case .generic:
            targetRange = 0.20...0.85
        }

        let band = samples.filter { targetRange.contains($0.progress) }
        guard !band.isEmpty else { return (nil, 0) }

        let bodyVectorX = poseSnapshot.root.x - poseSnapshot.neck.x
        let bodyVectorY = poseSnapshot.root.y - poseSnapshot.neck.y
        let bodyLength = max(0.001, hypot(bodyVectorX, bodyVectorY))
        let normalX = -bodyVectorY / bodyLength
        let normalY = bodyVectorX / bodyLength

        let depths = band.map { sample -> Double in
            let relativeX = sample.point.x - poseSnapshot.neck.x
            let relativeY = sample.point.y - poseSnapshot.neck.y
            return abs(Double(relativeX * normalX + relativeY * normalY)) / Double(bodyLength)
        }

        guard !depths.isEmpty else { return (nil, 0) }
        let average = depths.reduce(0, +) / Double(depths.count)
        let peak = depths.max() ?? average
        let motion = (average * 0.2 + peak * 0.8) * 2.0
        let confidence = min(1.0, Double(band.count) / 14.0)
        return (motion, confidence)
    }

    private func jointMotion(
        from poseSnapshot: ContourPoseSnapshot,
        style: ContourRepCounter.ExerciseStyle
    ) -> (motion: Double?, confidence: Double) {
        let joints = poseSnapshot.joints

        switch style {
        case .squatLike:
            let hipDrop = midpointProjection(
                upperA: point(named: "left_shoulder", in: joints),
                upperB: point(named: "right_shoulder", in: joints),
                lowerA: point(named: "left_ankle", in: joints),
                lowerB: point(named: "right_ankle", in: joints),
                centerA: point(named: "left_hip", in: joints),
                centerB: point(named: "right_hip", in: joints),
                fallbackUpperA: poseSnapshot.neck,
                fallbackLowerA: poseSnapshot.root
            )
            let kneeFlexion = averageOf(
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
            )

            let available = [hipDrop, kneeFlexion].compactMap { $0 }
            guard !available.isEmpty else { return (nil, 0) }
            return (available.reduce(0, +) / Double(available.count), min(1.0, Double(available.count) / 2.0))

        case .rowLike:
            let elbowFlexion = averageOf(
                flexionActivation(
                    shoulder: point(named: "left_shoulder", in: joints),
                    elbow: point(named: "left_elbow", in: joints),
                    wrist: point(named: "left_wrist", in: joints)
                ),
                flexionActivation(
                    shoulder: point(named: "right_shoulder", in: joints),
                    elbow: point(named: "right_elbow", in: joints),
                    wrist: point(named: "right_wrist", in: joints)
                )
            )
            let torsoCompression = averageOf(
                flexionActivation(
                    shoulder: point(named: "left_shoulder", in: joints),
                    hip: point(named: "left_hip", in: joints),
                    knee: point(named: "left_knee", in: joints)
                ),
                flexionActivation(
                    shoulder: point(named: "right_shoulder", in: joints),
                    hip: point(named: "right_hip", in: joints),
                    knee: point(named: "right_knee", in: joints)
                )
            )

            let available = [elbowFlexion, torsoCompression].compactMap { $0 }
            guard !available.isEmpty else { return (nil, 0) }
            return (available.reduce(0, +) / Double(available.count), min(1.0, Double(available.count) / 2.0))

        case .generic:
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
                )
            ]
            let available = candidates.compactMap { $0 }
            guard !available.isEmpty else { return (nil, 0) }
            return (available.reduce(0, +) / Double(available.count), min(1.0, Double(available.count) / 4.0))
        }
    }

    private func midpointProjection(
        upperA: CGPoint?,
        upperB: CGPoint?,
        lowerA: CGPoint?,
        lowerB: CGPoint?,
        centerA: CGPoint?,
        centerB: CGPoint?,
        fallbackUpperA: CGPoint,
        fallbackLowerA: CGPoint
    ) -> Double? {
        let upper = midpoint(upperA, upperB) ?? fallbackUpperA
        let lower = midpoint(lowerA, lowerB) ?? fallbackLowerA
        let center = midpoint(centerA, centerB)
        guard let center else { return nil }

        let axisX = lower.x - upper.x
        let axisY = lower.y - upper.y
        let length = max(0.001, hypot(axisX, axisY))
        let unitX = axisX / length
        let unitY = axisY / length
        let projection = (center.x - upper.x) * unitX + (center.y - upper.y) * unitY
        return max(0, Double(projection))
    }

    private func flexionActivation(shoulder: CGPoint?, elbow: CGPoint?, wrist: CGPoint?) -> Double? {
        guard let shoulder, let elbow, let wrist else { return nil }
        return normalizedFlexion(from: Self.calculateAngle(a: shoulder, b: elbow, c: wrist))
    }

    private func flexionActivation(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> Double? {
        guard let shoulder, let hip, let knee else { return nil }
        return normalizedFlexion(from: Self.calculateAngle(a: shoulder, b: hip, c: knee))
    }

    private func flexionActivation(hip: CGPoint?, knee: CGPoint?, ankle: CGPoint?) -> Double? {
        guard let hip, let knee, let ankle else { return nil }
        return normalizedFlexion(from: Self.calculateAngle(a: hip, b: knee, c: ankle))
    }

    private func midpoint(_ a: CGPoint?, _ b: CGPoint?) -> CGPoint? {
        guard let a, let b else { return nil }
        return CGPoint(x: (a.x + b.x) * 0.5, y: (a.y + b.y) * 0.5)
    }

    private func point(named name: String, in joints: [String: CGPoint]) -> CGPoint? {
        if let point = joints[name] {
            return point
        }
        if !name.hasPrefix("left_"), let point = joints["left_\(name)"] {
            return point
        }
        if !name.hasPrefix("right_"), let point = joints["right_\(name)"] {
            return point
        }
        return nil
    }

    private func averageOf(_ values: Double?...) -> Double? {
        let filtered = values.compactMap { $0 }
        guard !filtered.isEmpty else { return nil }
        return filtered.reduce(0, +) / Double(filtered.count)
    }

    private func normalizedFlexion(from angle: Float) -> Double {
        let value = (180.0 - Double(angle)) / 90.0
        return min(max(value, 0), 1)
    }

    private static func calculateAngle(a: CGPoint, b: CGPoint, c: CGPoint) -> Float {
        let ab = CGPoint(x: a.x - b.x, y: a.y - b.y)
        let cb = CGPoint(x: c.x - b.x, y: c.y - b.y)
        let dot = ab.x * cb.x + ab.y * cb.y
        let cross = ab.x * cb.y - ab.y * cb.x
        let angle = atan2(cross, dot) * 180 / .pi
        return Float(abs(angle))
    }
    
    var formAccuracyScore: Double? {
        let state = analysisState
        guard state.analyzedFrameCount > 0 else { return nil }
        return (Double(state.correctFrameCount) / Double(state.analyzedFrameCount)) * 100.0
    }
    
    var topFormInsights: [String] {
        analysisState.feedbackCounts
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key < rhs.key
                }
                return lhs.value > rhs.value
            }
            .prefix(3)
            .map { Self.descriptiveInsight(for: $0.key) }
    }
    
    private static func formatElapsedTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private static func descriptiveInsight(for feedback: String) -> String {
        let normalized = feedback.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if normalized.contains("upper back rounded") {
            return "Your upper back started rounding during the set. Keep your chest lifted, engage your core, and think about lengthening through the spine on every rep."
        }
        
        if normalized.contains("back not straight") {
            return "Your back drifted out of a neutral position during the movement. Slow the rep down slightly and brace through the midsection so your torso stays more stable."
        }
        
        return "Your posture became inconsistent in this phase of the movement. Focus on controlled reps and keep the spine stacked and steady from start to finish."
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        let localPhase = self.phase
        
        if localPhase == .detectingPerson {
            performPoseDetection(pixelBuffer: pixelBuffer, requestHandler: requestHandler)
        } else if localPhase == .analyzing {
            performContourDetection(pixelBuffer: pixelBuffer, requestHandler: requestHandler)
        }
    }
    
    private func performPoseDetection(pixelBuffer: CVPixelBuffer, requestHandler: VNImageRequestHandler) {
        let poseRequest = VNDetectHumanBodyPoseRequest()
        do {
            try requestHandler.perform([poseRequest])
            if let observation = poseRequest.results?.first {
                // Check if sideways (nose and ear X difference is significant, and only one eye/ear is clearly visible or nose is far from center of face)
                // A simple heuristic: try to get nose and one ear.
                if let nose = try? observation.recognizedPoint(.nose),
                   let rightEar = try? observation.recognizedPoint(.rightEar),
                   let leftEar = try? observation.recognizedPoint(.leftEar) {
                    
                    let noseConfidence = nose.confidence > 0.3
                    let rightEarConfidence = rightEar.confidence > 0.3
                    let leftEarConfidence = leftEar.confidence > 0.3
                    
                    // Simple logic for side profile: We see nose clearly, and exactly one ear clearly, or distance is significant.
                    if noseConfidence && (rightEarConfidence != leftEarConfidence) {
                        DispatchQueue.main.async {
                            if self.phase == .detectingPerson {
                                self.startTimer()
                            }
                        }
                    } else if noseConfidence && rightEarConfidence && leftEarConfidence {
                        // If both ears visible, check horizontal distance
                        let dR = abs(nose.location.x - rightEar.location.x)
                        let dL = abs(nose.location.x - leftEar.location.x)
                        if max(dR, dL) > 0.05 {
                            DispatchQueue.main.async {
                                if self.phase == .detectingPerson {
                                    self.startTimer()
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Pose detection failed: \(error)")
        }
    }
    
    private func performContourDetection(pixelBuffer: CVPixelBuffer, requestHandler: VNImageRequestHandler) {
        let segRequest = VNGeneratePersonSegmentationRequest()
        segRequest.qualityLevel = .accurate
        segRequest.outputPixelFormat = kCVPixelFormatType_OneComponent8
        contourFrameIndex += 1
        let shouldRefreshPose = cachedContourPose == nil || contourFrameIndex % poseRefreshInterval == 0
        let poseRequest = shouldRefreshPose ? VNDetectHumanBodyPoseRequest() : nil
        
        autoreleasepool {
        do {
            if let poseRequest {
                try requestHandler.perform([segRequest, poseRequest])
                if let pose = poseRequest.results?.first,
                   let snapshot = makeContourPoseSnapshot(from: pose) {
                    cachedContourPose = snapshot
                }
            } else {
                try requestHandler.perform([segRequest])
            }
            
            guard let maskObservation = segRequest.results?.first else { return }
            guard let poseSnapshot = cachedContourPose else { return }
            let maskPixelBuffer = maskObservation.pixelBuffer
            
            // Extract silhouette edge from mask using perpendicular spine sampling
            CVPixelBufferLockBaseAddress(maskPixelBuffer, .readOnly)
            defer { CVPixelBufferUnlockBaseAddress(maskPixelBuffer, .readOnly) }
            
            guard let baseAddress = CVPixelBufferGetBaseAddress(maskPixelBuffer) else { return }
            let width = CVPixelBufferGetWidth(maskPixelBuffer)
            let height = CVPixelBufferGetHeight(maskPixelBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(maskPixelBuffer)
            let bufferPointer = baseAddress.assumingMemoryBound(to: UInt8.self)
            
            var edgePoints: [CGPoint] = []
            var contourSamples: [ContourSample] = []

            let neck = poseSnapshot.neck
            let root = poseSnapshot.root
            let minY = poseSnapshot.minY
            let maxY = poseSnapshot.maxY
            
            // Spine vector
            let vx = root.x - neck.x
            let vy = root.y - neck.y
            let length = max(0.001, sqrt(vx * vx + vy * vy))
            
            // Normal vector pointing to the back
            var nx = vy / length
            var ny = -vx / length
            if !poseSnapshot.isFacingLeft {
                nx = -nx
                ny = -ny
            }
            
            // Sample along the spine from slightly above neck (-0.1) to root (1.0)
            let sampleCount = 50
            for i in 0...sampleCount {
                let t = -0.1 + 1.1 * (CGFloat(i) / CGFloat(sampleCount))
                let px = neck.x + t * vx
                let py = neck.y + t * vy
                
                if py < minY - 0.06 || py > maxY + 0.04 {
                    continue
                }
                
                // March outward along normal
                var foundEdge = false
                var lastValid = CGPoint(x: px, y: py)
                var insideBody = false
                
                for step in stride(from: 0.0, to: 0.4, by: 0.005) {
                    let sampleX = px + CGFloat(step) * nx
                    let sampleY = py + CGFloat(step) * ny
                    
                    let pxInt = Int(sampleX * CGFloat(width))
                    let pyInt = Int(sampleY * CGFloat(height))
                    
                    if pxInt >= 0 && pxInt < width && pyInt >= 0 && pyInt < height {
                        let pixel = bufferPointer[pyInt * bytesPerRow + pxInt]
                        if pixel > 128 {
                            insideBody = true
                            lastValid = CGPoint(x: sampleX, y: sampleY)
                        } else if insideBody {
                            foundEdge = true
                            break
                        }
                    } else {
                        break
                    }
                }
                
                if foundEdge {
                    edgePoints.append(lastValid)
                    contourSamples.append(
                        ContourSample(
                            point: lastValid,
                            progress: min(max(t, 0), 1)
                        )
                    )
                }
            }
            
            // Apply Moving Average Smoothing to reduce contour noise
            if edgePoints.count > 4 {
                var smoothed: [CGPoint] = []
                var smoothedSamples: [ContourSample] = []
                let window = 2
                for i in 0..<edgePoints.count {
                    let start = max(0, i - window)
                    let end = min(edgePoints.count - 1, i + window)
                    var sumX: CGFloat = 0
                    var sumY: CGFloat = 0
                    for j in start...end {
                        sumX += edgePoints[j].x
                        sumY += edgePoints[j].y
                    }
                    let count = CGFloat(end - start + 1)
                    smoothed.append(CGPoint(x: sumX / count, y: sumY / count))
                    smoothedSamples.append(
                        ContourSample(
                            point: CGPoint(x: sumX / count, y: sumY / count),
                            progress: contourSamples[i].progress
                        )
                    )
                }
                edgePoints = smoothed
                contourSamples = smoothedSamples
            }
            
            // Curve analysis
            var straight = true
            var msg = "Straight"
            if edgePoints.count > 5 {
                let top = edgePoints.first!
                let bottom = edgePoints.last!
                
                var maxDev: CGFloat = 0
                var isUpperBackIssue = false
                
                for (index, p) in edgePoints.enumerated() {
                    let A = bottom.y - top.y
                    let B = top.x - bottom.x
                    let C = bottom.x * top.y - top.x * bottom.y
                    
                    let dist = abs(A * p.x + B * p.y + C) / max(0.001, sqrt(A*A + B*B))
                    
                    // Robust 2D cross-product to determine side (avoids division by zero for horizontal backs)
                    let cross = (bottom.x - top.x) * (p.y - top.y) - (bottom.y - top.y) * (p.x - top.x)
                    let isOutward = poseSnapshot.isFacingLeft ? (cross < 0) : (cross > 0)
                    
                    if isOutward {
                        let isUpper = CGFloat(index) / CGFloat(edgePoints.count) < 0.4
                        let threshold: CGFloat = isUpper ? 0.02 : 0.03
                        
                        if dist > threshold && dist > maxDev {
                            maxDev = dist
                            straight = false
                            if isUpper {
                                isUpperBackIssue = true
                            }
                        }
                    }
                }
                
                if !straight {
                    msg = isUpperBackIssue ? "Upper back rounded" : "Mistake: Back not straight"
                }
            }
            
            var state = analysisState
            state.analyzedFrameCount += 1
            if straight {
                state.correctFrameCount += 1
            } else {
                state.feedbackCounts[msg, default: 0] += 1
            }
            analysisState = state

            let jointsSnapshot = poseSnapshot.joints
            repCountingQueue.async { [weak self] in
                guard let self else { return }
                let nextRepCount = self.jointRepCounter.update(with: jointsSnapshot)
                DispatchQueue.main.async {
                    self.repCount = nextRepCount
                }
            }

            let nextAnalyzedFrameCount = state.analyzedFrameCount
            let nextCorrectFrameCount = state.correctFrameCount
            
            DispatchQueue.main.async {
                self.contourPoints = edgePoints
                self.isBackStraight = straight
                self.detectionFeedback = straight ? "Good Form" : msg
                self.analyzedFrameCount = nextAnalyzedFrameCount
                self.correctFrameCount = nextCorrectFrameCount
            }
            
        } catch {
            print("Contour detection failed: \(error)")
        }
        }
    }
}
