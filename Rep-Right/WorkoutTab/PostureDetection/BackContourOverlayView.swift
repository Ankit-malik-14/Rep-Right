import SwiftUI

struct BackContourOverlayView: View {
    var detector: BackContourDetector
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard let first = detector.contourPoints.first else { return }
                path.move(to: CGPoint(x: first.x * geometry.size.width, y: first.y * geometry.size.height))
                for p in detector.contourPoints.dropFirst() {
                    path.addLine(to: CGPoint(x: p.x * geometry.size.width, y: p.y * geometry.size.height))
                }
            }
            .stroke(detector.isBackStraight ? Color.green : Color.red, lineWidth: 4)
        }
    }
}

struct WorkoutCameraOverlayView: View {
    let repCount: Int
    let targetReps: Int?
    let elapsedFormatted: String
    let feedbackTitle: String?
    let feedbackMessage: String?
    let accentColor: Color
    let utilityIcon: String
    let onUtilityTap: () -> Void
    let onFinishTap: () -> Void
    
    @State private var dismissedFeedbackKey: String?
    
    var body: some View {
        VStack(spacing: 0) {
            if let feedbackTitle, let feedbackMessage, shouldShowFeedback(message: feedbackMessage) {
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(accentColor.opacity(0.18))
                        .frame(width: 68, height: 68)
                        .overlay {
                            Image(systemName: "exclamationmark")
                                .font(.title2.bold())
                                .foregroundStyle(accentColor)
                        }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(feedbackTitle)
                            .font(.headline)
                            .foregroundStyle(accentColor)
                        Text(feedbackMessage)
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer(minLength: 12)
                    
                    Button("Dismiss") {
                        dismissedFeedbackKey = feedbackMessage
                    }
                    .font(.headline)
                    .foregroundStyle(.red)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal, 20)
                .padding(.top, 26)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    metricCard(title: "Reps", value: repText)
                    metricCard(title: "Timer", value: elapsedFormatted)
                }
                
                HStack(spacing: 14) {
                    Button(action: onUtilityTap) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .frame(width: 72, height: 72)
                            .overlay {
                                Image(systemName: utilityIcon)
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }
                    }
                    
                    Button(action: onFinishTap) {
                        Text("Finish Set")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 72)
                            .background(accentColor, in: RoundedRectangle(cornerRadius: 28))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
    }
    
    private var repText: String {
        if let targetReps {
            return "\(repCount)/\(targetReps)"
        }
        return "\(repCount)"
    }
    
    private func metricCard(title: String, value: String) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
            Text(value)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(accentColor)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 118)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
    }
    
    private func shouldShowFeedback(message: String) -> Bool {
        dismissedFeedbackKey != message
    }
}
