import Foundation

private struct JointRepProfile {
    let trigger: Double
    let peak: Double
    let reset: Double
    let minimumRiseDelta: Double
    let refractoryFrames: Int
    let maxCycleFrames: Int
    let signalProvider: ([String: CGPoint]) -> Double?
}

final class JointRepCounter {
    private enum Phase {
        case idle
        case tracking
        case refractory
    }

    private struct State {
        var phase: Phase = .idle
        var peakSeen: Bool = false
        var framesInCycle: Int = 0
        var refractoryFramesRemaining: Int = 0
        var smoothedActivation: Double?
        var isArmed: Bool = false
    }

    enum ExerciseStyle {
        case squatLike
        case rowLike
        case generic
    }

    private var state = State()
    private(set) var repCount: Int = 0
    private var profile = JointRepCounter.profile(for: .generic)

    func reset() {
        repCount = 0
        state = State()
    }

    func configure(exerciseName: String) {
        profile = Self.profile(for: Self.style(for: exerciseName))
        state = State()
    }

    func update(with joints: [String: CGPoint]) -> Int {
        guard let rawActivation = profile.signalProvider(joints) else { return repCount }

        let previousActivation = state.smoothedActivation
        let activation: Double
        if let previous = previousActivation {
            activation = previous * 0.6 + rawActivation * 0.4
        } else {
            activation = rawActivation
        }
        state.smoothedActivation = activation

        let activationDelta = activation - (previousActivation ?? activation)

        switch state.phase {
        case .idle:
            state.framesInCycle = 0

            if activation <= profile.reset {
                state.isArmed = true
            }

            if state.isArmed,
               activation >= profile.trigger,
               activationDelta >= profile.minimumRiseDelta {
                state.phase = .tracking
                state.peakSeen = activation >= profile.peak
                state.framesInCycle = 1
            }

        case .tracking:
            state.framesInCycle += 1

            if activation >= profile.peak {
                state.peakSeen = true
            }

            if state.peakSeen,
               activation <= profile.reset,
               activationDelta <= 0 {
                repCount += 1
                state.phase = .refractory
                state.refractoryFramesRemaining = profile.refractoryFrames
                state.peakSeen = false
                state.isArmed = false
                state.framesInCycle = 0
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

        return repCount
    }

    private nonisolated static func style(for exerciseName: String) -> ExerciseStyle {
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

    private nonisolated static func profile(for style: ExerciseStyle) -> JointRepProfile {
        switch style {
        case .squatLike:
            return JointRepProfile(
                trigger: 0.22,
                peak: 0.48,
                reset: 0.16,
                minimumRiseDelta: 0.008,
                refractoryFrames: 8,
                maxCycleFrames: 120,
                signalProvider: Self.squatActivation(using:)
            )
        case .rowLike:
            return JointRepProfile(
                trigger: 0.20,
                peak: 0.44,
                reset: 0.15,
                minimumRiseDelta: 0.008,
                refractoryFrames: 8,
                maxCycleFrames: 120,
                signalProvider: Self.rowActivation(using:)
            )
        case .generic:
            return JointRepProfile(
                trigger: 0.18,
                peak: 0.42,
                reset: 0.14,
                minimumRiseDelta: 0.008,
                refractoryFrames: 8,
                maxCycleFrames: 120,
                signalProvider: Self.genericActivation(using:)
            )
        }
    }

    private nonisolated static func squatActivation(using joints: [String: CGPoint]) -> Double? {
        let hipFlexion = averageOf(
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

        let available = [hipFlexion, kneeFlexion].compactMap { $0 }
        guard !available.isEmpty else { return nil }
        return available.min()
    }

    private nonisolated static func rowActivation(using joints: [String: CGPoint]) -> Double? {
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
        guard !available.isEmpty else { return nil }
        return available.min()
    }

    private nonisolated static func genericActivation(using joints: [String: CGPoint]) -> Double? {
        let candidates: [Double?] = [
            squatActivation(using: joints),
            rowActivation(using: joints)
        ]
        let available = candidates.compactMap { $0 }
        guard !available.isEmpty else { return nil }
        return available.reduce(0, +) / Double(available.count)
    }

    private nonisolated static func point(named name: String, in joints: [String: CGPoint]) -> CGPoint? {
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

    private nonisolated static func averageOf(_ values: Double?...) -> Double? {
        let filtered = values.compactMap { $0 }
        guard !filtered.isEmpty else { return nil }
        return filtered.reduce(0, +) / Double(filtered.count)
    }

    private nonisolated static func flexionActivation(shoulder: CGPoint?, elbow: CGPoint?, wrist: CGPoint?) -> Double? {
        guard let shoulder, let elbow, let wrist else { return nil }
        return normalizedFlexion(from: calculateAngle(a: shoulder, b: elbow, c: wrist))
    }

    private nonisolated static func flexionActivation(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> Double? {
        guard let shoulder, let hip, let knee else { return nil }
        return normalizedFlexion(from: calculateAngle(a: shoulder, b: hip, c: knee))
    }

    private nonisolated static func flexionActivation(hip: CGPoint?, knee: CGPoint?, ankle: CGPoint?) -> Double? {
        guard let hip, let knee, let ankle else { return nil }
        return normalizedFlexion(from: calculateAngle(a: hip, b: knee, c: ankle))
    }

    private nonisolated static func normalizedFlexion(from angle: Float) -> Double {
        let value = (180.0 - Double(angle)) / 90.0
        return min(max(value, 0), 1)
    }

    private nonisolated static func calculateAngle(a: CGPoint, b: CGPoint, c: CGPoint) -> Float {
        let ab = CGPoint(x: a.x - b.x, y: a.y - b.y)
        let cb = CGPoint(x: c.x - b.x, y: c.y - b.y)
        let dot = ab.x * cb.x + ab.y * cb.y
        let cross = ab.x * cb.y - ab.y * cb.x
        let angle = atan2(cross, dot) * 180 / .pi
        return Float(abs(angle))
    }
}
