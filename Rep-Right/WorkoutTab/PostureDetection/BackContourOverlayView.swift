import SwiftUI

struct BackContourOverlayView: View {
    var detector: BackContourDetector
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw Contour
                Path { path in
                    guard let first = detector.contourPoints.first else { return }
                    path.move(to: CGPoint(x: first.x * geometry.size.width, y: first.y * geometry.size.height))
                    for p in detector.contourPoints.dropFirst() {
                        path.addLine(to: CGPoint(x: p.x * geometry.size.width, y: p.y * geometry.size.height))
                    }
                }
                .stroke(detector.isBackStraight ? Color.green : Color.red, lineWidth: 4)
                
                // Mistake Card
                if !detector.isBackStraight {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                                .font(.title2)
                            Text(detector.detectionFeedback)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 5)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
    }
}
