//
//  CameraPreviewView.swift
//  Rep_Right
//
//  Created by Mayurakshi Das on 06/04/26.
//

import SwiftUI
import SwiftUI
import AVFoundation
import Vision

// MARK: - Live camera feed
struct CameraPreviewView: UIViewRepresentable {
    let service: PoseDetectionService

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer = service.makePreviewLayer()
        if let layer = view.previewLayer {
            view.layer.addSublayer(layer)
        }
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        DispatchQueue.main.async {
            uiView.previewLayer?.frame = uiView.bounds
        }
    }

    class PreviewUIView: UIView {
        var previewLayer: AVCaptureVideoPreviewLayer?
        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer?.frame = bounds
        }
    }
}

// MARK: - Skeleton overlay
struct SkeletonOverlayView: View {
    let points: [VNHumanBodyPoseObservation.JointName: CGPoint]

    private let connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
        (.leftShoulder,  .rightShoulder),
        (.leftShoulder,  .leftElbow),
        (.leftElbow,     .leftWrist),
        (.rightShoulder, .rightElbow),
        (.rightElbow,    .rightWrist),
        (.leftShoulder,  .leftHip),
        (.rightShoulder, .rightHip),
        (.leftHip,       .rightHip),
        (.leftHip,       .leftKnee),
        (.leftKnee,      .leftAnkle),
        (.rightHip,      .rightKnee),
        (.rightKnee,     .rightAnkle)
    ]

    var body: some View {
        Canvas { context, size in
            for (jointA, jointB) in connections {
                guard let a = screenPoint(jointA, in: size),
                      let b = screenPoint(jointB, in: size) else { continue }
                var path = Path()
                path.move(to: a)
                path.addLine(to: b)
                context.stroke(path, with: .color(.orange.opacity(0.85)), lineWidth: 3)
            }
            for (_, point) in points {
                let sp = CGPoint(x: point.x * size.width, y: point.y * size.height)
                let rect = CGRect(x: sp.x - 5, y: sp.y - 5, width: 10, height: 10)
                context.fill(Path(ellipseIn: rect), with: .color(.white))
                context.stroke(Path(ellipseIn: rect), with: .color(.orange), lineWidth: 2)
            }
        }
    }

    private func screenPoint(_ joint: VNHumanBodyPoseObservation.JointName,
                              in size: CGSize) -> CGPoint? {
        guard let pt = points[joint] else { return nil }
        return CGPoint(x: pt.x * size.width, y: pt.y * size.height)
    }
}

// MARK: - Full screen live assistance view
struct LiveAssistanceView: View {
    var exercise: Exercise
    @State private var service = PoseDetectionService()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            GeometryReader { geo in
                ZStack {
                    CameraPreviewView(service: service)
                        .ignoresSafeArea()
                    SkeletonOverlayView(points: service.detectedPoints)
                        .ignoresSafeArea()
                }
            }

            VStack {
                // Top bar
                HStack {
                    Button {
                        service.stopCamera()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                    }
                    Spacer()
                    VStack {
                        Text("\(service.repCount)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.orange)
                        Text("Reps")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
                    .padding()
                }

                Spacer()

                // Bottom HUD
                VStack(spacing: 12) {
                    HStack {
                        Text("Form")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(Int(service.formAccuracy))%")
                            .font(.title2.bold())
                            .foregroundStyle(accuracyColor)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.white.opacity(0.2))
                                .frame(height: 10)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(accuracyColor)
                                .frame(width: geo.size.width * (service.formAccuracy / 100), height: 10)
                                .animation(.easeOut(duration: 0.3), value: service.formAccuracy)
                        }
                    }.frame(height: 10)

                    Divider().overlay(.white.opacity(0.3))

                    ForEach(service.currentFeedback, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text(tip).font(.subheadline).foregroundStyle(.white)
                            Spacer()
                        }
                    }

                    ForEach(service.currentRisks, id: \.self) { risk in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                            Text(risk).font(.subheadline).foregroundStyle(.white)
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 20))
                .padding()
            }
        }
        .onAppear { service.setupCamera(for: exercise.name) }
        .onDisappear { service.stopCamera() }
    }

    var accuracyColor: Color {
        switch service.formAccuracy {
        case 0..<40:  return .red
        case 40..<75: return .orange
        default:      return .green
        }
    }
}
