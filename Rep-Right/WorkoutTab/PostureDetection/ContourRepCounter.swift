import Foundation

struct ContourRepMeasurement {
    let contourMotion: Double?
    let contourConfidence: Double
    let jointMotion: Double?
    let jointConfidence: Double
}

private struct ContourRepProfile {
    let entryTrigger: Double
    let peakTrigger: Double
    let resetTrigger: Double
    let minimumRiseDelta: Double
    let refractoryFrames: Int
    let maxCycleFrames: Int
    let baselineAdaptation: Double
}

final class ContourRepCounter {
    private enum Phase {
        case idle
        case tracking
        case refractory
    }

    private struct State {
        var phase: Phase = .idle
        var baselineMotion: Double?
        var lastMotion: Double?
        var peakMotion: Double = 0
        var peakSeen: Bool = false
        var framesInCycle: Int = 0
        var refractoryFramesRemaining: Int = 0
        var isArmed: Bool = false
    }

    enum ExerciseStyle {
        case squatLike
        case rowLike
        case generic
    }

    private var state = State()
    private(set) var repCount: Int = 0
    private var profile = ContourRepCounter.profile(for: .generic)

    func reset() {
        repCount = 0
        state = State()
    }

    func configure(exerciseName: String) {
        profile = Self.profile(for: Self.style(for: exerciseName))
        state = State()
    }

    func update(with measurement: ContourRepMeasurement?) {
        guard let motion = Self.resolveMotion(from: measurement) else { return }

        if state.baselineMotion == nil {
            state.baselineMotion = motion
            state.lastMotion = motion
            return
        }

        let baseline = state.baselineMotion ?? motion
        let normalizedMotion = max(0, motion - baseline)
        let previousMotion = state.lastMotion ?? motion
        let motionDelta = motion - previousMotion
        state.lastMotion = motion

        switch state.phase {
        case .idle:
            state.framesInCycle = 0

            if normalizedMotion <= profile.resetTrigger {
                state.isArmed = true
                state.baselineMotion = baseline * (1.0 - profile.baselineAdaptation) + motion * profile.baselineAdaptation
            }

            if state.isArmed,
               normalizedMotion >= profile.entryTrigger,
               motionDelta >= profile.minimumRiseDelta {
                state.phase = .tracking
                state.peakSeen = false
                state.peakMotion = motion
                state.framesInCycle = 1
            }

        case .tracking:
            state.framesInCycle += 1
            state.peakMotion = max(state.peakMotion, motion)

            if normalizedMotion >= profile.peakTrigger {
                state.peakSeen = true
            }

            let hasRebounded = state.peakSeen &&
                normalizedMotion <= profile.resetTrigger &&
                motionDelta <= 0

            if hasRebounded {
                repCount += 1
                state.phase = .refractory
                state.refractoryFramesRemaining = profile.refractoryFrames
                state.peakSeen = false
                state.isArmed = false
                state.framesInCycle = 0
                state.baselineMotion = motion
            } else if state.framesInCycle >= profile.maxCycleFrames {
                state.phase = .idle
                state.peakSeen = false
                state.framesInCycle = 0
                state.isArmed = false
            }

        case .refractory:
            state.refractoryFramesRemaining -= 1
            if state.refractoryFramesRemaining <= 0 {
                state.phase = .idle
                state.framesInCycle = 0
            }
        }
    }

    private static func resolveMotion(from measurement: ContourRepMeasurement?) -> Double? {
        guard let measurement else { return nil }

        let contour = measurement.contourMotion
        let joint = measurement.jointMotion
        let contourConfidence = max(measurement.contourConfidence, 0)
        let jointConfidence = max(measurement.jointConfidence, 0)
        let minimumConfidence: Double = 0.15

        switch (contour, joint) {
        case let (lhs?, rhs?):
            let contourReady = contourConfidence >= minimumConfidence
            let jointReady = jointConfidence >= minimumConfidence

            if contourReady && !jointReady {
                return lhs
            }
            if jointReady && !contourReady {
                return rhs
            }

            if contourConfidence > jointConfidence + 0.1 {
                return lhs
            }
            if jointConfidence > contourConfidence + 0.1 {
                return rhs
            }

            return max(lhs, rhs)
        case let (lhs?, nil):
            return lhs
        case let (nil, rhs?):
            return rhs
        default:
            return nil
        }
    }

    private static func style(for exerciseName: String) -> ExerciseStyle {
        let normalized = exerciseName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if normalized.contains("squat") || normalized.contains("lunge") || normalized.contains("deadlift") {
            return .squatLike
        }

        if normalized.contains("row") || normalized.contains("pull") {
            return .rowLike
        }

        return .generic
    }

    private static func profile(for style: ExerciseStyle) -> ContourRepProfile {
        switch style {
        case .squatLike:
            return ContourRepProfile(
                entryTrigger: 0.010,
                peakTrigger: 0.022,
                resetTrigger: 0.012,
                minimumRiseDelta: 0.0015,
                refractoryFrames: 8,
                maxCycleFrames: 120,
                baselineAdaptation: 0.08
            )
        case .rowLike:
            return ContourRepProfile(
                entryTrigger: 0.008,
                peakTrigger: 0.018,
                resetTrigger: 0.010,
                minimumRiseDelta: 0.0010,
                refractoryFrames: 8,
                maxCycleFrames: 120,
                baselineAdaptation: 0.08
            )
        case .generic:
            return ContourRepProfile(
                entryTrigger: 0.009,
                peakTrigger: 0.020,
                resetTrigger: 0.011,
                minimumRiseDelta: 0.0010,
                refractoryFrames: 8,
                maxCycleFrames: 120,
                baselineAdaptation: 0.08
            )
        }
    }
}
