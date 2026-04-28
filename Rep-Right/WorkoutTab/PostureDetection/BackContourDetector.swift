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
    
    // Timer state
    var timerTime: Int = 3
    private var timer: Timer?
    
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
                    if self.currentCameraPosition == .front {
                        connection.isVideoMirrored = true
                    }
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
    }
    
    func startDetectingPerson() {
        DispatchQueue.main.async {
            self.phase = .detectingPerson
            if self.detectionFeedback == "" || self.detectionFeedback == "Analyzing..." {
                self.detectionFeedback = "Please stand sideways in the frame"
            }
        }
    }
    
    func startTimer() {
        DispatchQueue.main.async {
            guard self.phase == .detectingPerson else { return }
            self.phase = .timer
            self.timerTime = 3
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.timerTime > 1 {
                    self.timerTime -= 1
                } else {
                    self.timer?.invalidate()
                    self.phase = .analyzing
                    self.detectionFeedback = "Analyzing..."
                }
            }
        }
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
        // First get the mask
        let segRequest = VNGeneratePersonSegmentationRequest()
        segRequest.qualityLevel = .accurate
        segRequest.outputPixelFormat = kCVPixelFormatType_OneComponent8
        
        // Also get body pose to find neck and hip bounds
        let poseRequest = VNDetectHumanBodyPoseRequest()
        
        do {
            try requestHandler.perform([segRequest, poseRequest])
            
            guard let maskObservation = segRequest.results?.first else { return }
            let maskPixelBuffer = maskObservation.pixelBuffer
            
            // Get Neck and Hip bounds
            var minY: CGFloat = CGFloat(0.0) // Neck
            var maxY: CGFloat = CGFloat(1.0) // Hip
            var isFacingLeft = true // Nose X < Ear X
            
            if let pose = poseRequest.results?.first {
                if let neck = try? pose.recognizedPoint(.neck), neck.confidence > 0.3 {
                    // Vision coordinates are bottom-left origin. We will flip Y later.
                    minY = CGFloat(1.0) - CGFloat(neck.location.y)
                }
                if let root = try? pose.recognizedPoint(.root), root.confidence > 0.3 {
                    maxY = CGFloat(1.0) - CGFloat(root.location.y)
                }
                
                // Determine orientation to know which side is the back
                if let nose = try? pose.recognizedPoint(.nose), let rightEar = try? pose.recognizedPoint(.rightEar), let leftEar = try? pose.recognizedPoint(.leftEar) {
                    let ear = rightEar.confidence > leftEar.confidence ? rightEar : leftEar
                    if nose.confidence > 0.1 && ear.confidence > 0.1 {
                        isFacingLeft = nose.location.x < ear.location.x
                    }
                }
            }
            
            // Ensure Y bounds are valid
            if minY > maxY {
                let temp = minY
                minY = maxY
                maxY = temp
            }
            
            // Extract silhouette edge from mask using perpendicular spine sampling
            CVPixelBufferLockBaseAddress(maskPixelBuffer, .readOnly)
            defer { CVPixelBufferUnlockBaseAddress(maskPixelBuffer, .readOnly) }
            
            guard let baseAddress = CVPixelBufferGetBaseAddress(maskPixelBuffer) else { return }
            let width = CVPixelBufferGetWidth(maskPixelBuffer)
            let height = CVPixelBufferGetHeight(maskPixelBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(maskPixelBuffer)
            let bufferPointer = baseAddress.assumingMemoryBound(to: UInt8.self)
            
            var edgePoints: [CGPoint] = []
            
            if let pose = poseRequest.results?.first,
               let neckPt = try? pose.recognizedPoint(.neck), neckPt.confidence > 0.3,
               let rootPt = try? pose.recognizedPoint(.root), rootPt.confidence > 0.3 {
                
                // Flip Y for UIKit coordinates
                let neck = CGPoint(x: neckPt.location.x, y: 1.0 - neckPt.location.y)
                let root = CGPoint(x: rootPt.location.x, y: 1.0 - rootPt.location.y)
                
                // Spine vector
                let vx = root.x - neck.x
                let vy = root.y - neck.y
                let length = max(0.001, sqrt(vx*vx + vy*vy))
                
                // Normal vector pointing to the back
                var nx = vy / length
                var ny = -vx / length
                if !isFacingLeft {
                    nx = -nx
                    ny = -ny
                }
                
                // Sample along the spine from slightly above neck (-0.1) to root (1.0)
                let sampleCount = 50
                for i in 0...sampleCount {
                    let t = -0.1 + 1.1 * (CGFloat(i) / CGFloat(sampleCount))
                    let px = neck.x + t * vx
                    let py = neck.y + t * vy
                    
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
                            if pixel > 128 { // Lowered threshold back to 128 to ensure strong detection
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
                    }
                }
            }
            
            // Apply Moving Average Smoothing to reduce contour noise
            if edgePoints.count > 4 {
                var smoothed: [CGPoint] = []
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
                }
                edgePoints = smoothed
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
                    let isOutward = isFacingLeft ? (cross < 0) : (cross > 0)
                    
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
            
            DispatchQueue.main.async {
                self.contourPoints = edgePoints
                self.isBackStraight = straight
                self.detectionFeedback = straight ? "Good Form" : msg
            }
            
        } catch {
            print("Contour detection failed: \(error)")
        }
    }
}

