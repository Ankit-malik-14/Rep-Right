//
//  PoseDetectionService.swift
//  Rep_Right
//
//  Created by Mayurakshi Das on 06/04/26.
//

//
//  PoseDetectionService.swift
//  Rep-Right
//

import AVFoundation
import Vision
import SwiftUI
import Combine

// MARK: - Joint Angle Result
struct JointAngles {
    var kneeAngle: Double = 0
    var hipAngle: Double = 0
    var elbowAngle: Double = 0
    var bodyLineAngle: Double = 0
    var spineAngle: Double = 0
}

// MARK: - Pose Detection Service
@Observable
class PoseDetectionService: NSObject {

    var formAccuracy: Double = 0.0
    var jointAngles = JointAngles()
    var detectedPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
    var isRunning: Bool = false
    var currentFeedback: [String] = []
    var currentRisks: [String] = []
    var repCount: Int = 0

    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.repright.camera", qos: .userInteractive)
    private var currentExercise: String = ""
    private var repPhase: RepPhase = .up

    enum RepPhase { case up, down }

    func setupCamera(for exercise: String) {
        currentExercise = exercise
        repCount = 0
        repPhase = .up

        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high

            let position: AVCaptureDevice.Position = ["Push-Up", "Plank"].contains(exercise) ? .front : .back
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.captureSession.canAddInput(input) else { return }

            self.captureSession.addInput(input)
            self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
            }

            if let connection = self.videoOutput.connection(with: .video) {
                if connection.isVideoRotationAngleSupported(90) {
                    connection.videoRotationAngle = 90
                }
            }

            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
            DispatchQueue.main.async { self.isRunning = true }
        }
    }

    func stopCamera() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
            DispatchQueue.main.async { self?.isRunning = false }
        }
    }

    func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }
}

// MARK: - AVCapture Delegate
extension PoseDetectionService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
        guard let observation = request.results?.first else { return }
        processObservation(observation)
    }
}

// MARK: - Pose Processing
extension PoseDetectionService {

    private func processObservation(_ obs: VNHumanBodyPoseObservation) {
        let raw = try? obs.recognizedPoints(.all)
        guard let points = raw else { return }

        var mapped: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        for (key, point) in points where point.confidence > 0.3 {
            mapped[key] = CGPoint(x: point.location.x, y: 1 - point.location.y)
        }

        let angles = calculateAngles(from: mapped, exercise: currentExercise)
        let accuracy = calculateAccuracy(angles: angles, exercise: currentExercise)
        let feedback = generateFeedback(angles: angles, exercise: currentExercise)
        let risks = generateRisks(angles: angles, exercise: currentExercise)
        countReps(angles: angles, exercise: currentExercise)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.detectedPoints = mapped
            self.jointAngles = angles
            self.formAccuracy = accuracy
            self.currentFeedback = feedback
            self.currentRisks = risks
        }
    }

    private func calculateAngles(from points: [VNHumanBodyPoseObservation.JointName: CGPoint],
                                  exercise: String) -> JointAngles {
        var angles = JointAngles()
        func pt(_ j: VNHumanBodyPoseObservation.JointName) -> CGPoint? { points[j] }

        switch exercise {
        case "Bodyweight Squat":
            if let hip = pt(.rightHip), let knee = pt(.rightKnee), let ankle = pt(.rightAnkle) {
                angles.kneeAngle = angleBetween(a: hip, b: knee, c: ankle)
            }
            if let shoulder = pt(.rightShoulder), let hip = pt(.rightHip), let knee = pt(.rightKnee) {
                angles.hipAngle = angleBetween(a: shoulder, b: hip, c: knee)
            }
        case "Deadlift":
            if let shoulder = pt(.rightShoulder), let hip = pt(.rightHip), let ankle = pt(.rightAnkle) {
                angles.spineAngle = angleBetween(a: shoulder, b: hip, c: ankle)
            }
            if let hip = pt(.rightHip), let knee = pt(.rightKnee), let ankle = pt(.rightAnkle) {
                angles.kneeAngle = angleBetween(a: hip, b: knee, c: ankle)
            }
        case "Push-Up":
            if let shoulder = pt(.rightShoulder), let elbow = pt(.rightElbow), let wrist = pt(.rightWrist) {
                angles.elbowAngle = angleBetween(a: shoulder, b: elbow, c: wrist)
            }
        case "Plank":
            if let shoulder = pt(.rightShoulder), let hip = pt(.rightHip), let ankle = pt(.rightAnkle) {
                angles.bodyLineAngle = angleBetween(a: shoulder, b: hip, c: ankle)
            }
            if let ear = pt(.rightEar), let shoulder = pt(.rightShoulder), let hip = pt(.rightHip) {
                angles.spineAngle = angleBetween(a: ear, b: shoulder, c: hip)
            }
        default: break
        }
        return angles
    }

    private func angleBetween(a: CGPoint, b: CGPoint, c: CGPoint) -> Double {
        let ab = CGVector(dx: a.x - b.x, dy: a.y - b.y)
        let cb = CGVector(dx: c.x - b.x, dy: c.y - b.y)
        let dot = ab.dx * cb.dx + ab.dy * cb.dy
        let magAB = sqrt(ab.dx * ab.dx + ab.dy * ab.dy)
        let magCB = sqrt(cb.dx * cb.dx + cb.dy * cb.dy)
        guard magAB > 0, magCB > 0 else { return 0 }
        let cosAngle = max(-1, min(1, dot / (magAB * magCB)))
        return acos(cosAngle) * (180 / .pi)
    }

    private func calculateAccuracy(angles: JointAngles, exercise: String) -> Double {
        switch exercise {
        case "Bodyweight Squat":
            let kneeScore = scoreAngle(angles.kneeAngle, ideal: 97.5, tolerance: 12.5)
            let hipScore  = scoreAngle(angles.hipAngle,  ideal: 100,  tolerance: 20)
            return (kneeScore * 0.6 + hipScore * 0.4) * 100
        case "Deadlift":
            let spineScore = scoreAngle(angles.spineAngle, ideal: 170, tolerance: 10)
            let kneeScore  = scoreAngle(angles.kneeAngle,  ideal: 167, tolerance: 8)
            return (spineScore * 0.7 + kneeScore * 0.3) * 100
        case "Push-Up":
            return scoreAngle(angles.elbowAngle, ideal: 90, tolerance: 10) * 100
        case "Plank":
            let lineScore  = scoreAngle(angles.bodyLineAngle, ideal: 175, tolerance: 5)
            let spineScore = scoreAngle(angles.spineAngle,    ideal: 172, tolerance: 7)
            return (lineScore * 0.6 + spineScore * 0.4) * 100
        default: return 0
        }
    }

    private func scoreAngle(_ angle: Double, ideal: Double, tolerance: Double) -> Double {
        guard angle > 0 else { return 0 }
        return max(0, 1.0 - (abs(angle - ideal) / tolerance))
    }

    private func generateFeedback(angles: JointAngles, exercise: String) -> [String] {
        var tips: [String] = []
        switch exercise {
        case "Bodyweight Squat":
            if angles.kneeAngle > 110 { tips.append("Go deeper — aim for thighs parallel to floor.") }
            if angles.kneeAngle < 85  { tips.append("Don't go too deep — keep knees safe.") }
            if angles.hipAngle < 80   { tips.append("Keep your chest up, hinge from hips.") }
        case "Deadlift":
            if angles.spineAngle < 160 { tips.append("Keep your back neutral — avoid rounding.") }
            if angles.kneeAngle < 155  { tips.append("Drive through heels and extend knees.") }
        case "Push-Up":
            if angles.elbowAngle > 100 { tips.append("Lower your chest closer to the floor.") }
            if angles.elbowAngle < 80  { tips.append("Don't go too low — protect your shoulders.") }
        case "Plank":
            if angles.bodyLineAngle < 170 { tips.append("Raise your hips — keep a straight line.") }
            if angles.bodyLineAngle > 182 { tips.append("Lower your hips — don't pike up.") }
            if angles.spineAngle < 165   { tips.append("Keep your neck neutral, look at the floor.") }
        default: break
        }
        if tips.isEmpty { tips.append("Great form! Keep it up.") }
        return tips
    }

    private func generateRisks(angles: JointAngles, exercise: String) -> [String] {
        var risks: [String] = []
        switch exercise {
        case "Bodyweight Squat":
            if angles.kneeAngle < 70 { risks.append("Excessive knee depth — joint stress risk.") }
            if angles.hipAngle < 60  { risks.append("Forward lean — lower back strain risk.") }
        case "Deadlift":
            if angles.spineAngle < 145 { risks.append("Rounded back — disc herniation risk.") }
            if angles.spineAngle < 130 { risks.append("Severe spine flexion — stop and reset.") }
        case "Push-Up":
            if angles.elbowAngle < 70 { risks.append("Extreme elbow flexion — shoulder strain.") }
        case "Plank":
            if angles.bodyLineAngle < 160 { risks.append("Sagging hips — lower back compression.") }
        default: break
        }
        return risks
    }

    private func countReps(angles: JointAngles, exercise: String) {
        let primaryAngle: Double
        switch exercise {
        case "Bodyweight Squat": primaryAngle = angles.kneeAngle
        case "Deadlift":         primaryAngle = angles.kneeAngle
        case "Push-Up":          primaryAngle = angles.elbowAngle
        default: return
        }
        guard primaryAngle > 0 else { return }
        if repPhase == .up && primaryAngle < 100 {
            repPhase = .down
        } else if repPhase == .down && primaryAngle > 155 {
            repPhase = .up
            DispatchQueue.main.async { self.repCount += 1 }
        }
    }
}
