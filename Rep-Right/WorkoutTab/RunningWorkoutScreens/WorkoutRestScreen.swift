//
//  WorkoutRestScreen.swift
//  Rep-Right
//

import SwiftUI

struct WorkoutRestScreen: View {
    var manager: WorkoutSessionManager
    @State private var quoteIndex: Int
    
    init(manager: WorkoutSessionManager) {
        self.manager = manager
        self._quoteIndex = State(initialValue: Int.random(in: 0..<Self.quotes.count))
    }
    
    var body: some View {
        ZStack {
            // Dark immersive background
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.10),
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 36) {
                
                Spacer()
                
                Text("REST")
                    .font(.title3.bold())
                    .tracking(6)
                    .foregroundStyle(.white.opacity(0.4))
                
                // MARK: - Circular Countdown Timer
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.gray.opacity(0.12), lineWidth: 8)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: timerProgress)
                        .stroke(
                            Color.orange,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: manager.restTimeRemaining)
                    
                    // Time display
                    VStack(spacing: 4) {
                        Text(restTimeString)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                            .animation(.linear(duration: 0.3), value: manager.restTimeRemaining)
                        Text("remaining")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                .frame(width: 220, height: 220)
                
                // MARK: - Motivational Quote
                Text(Self.quotes[quoteIndex])
                    .font(.callout.italic())
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
                
                // MARK: - Next Exercise Preview
                if !manager.isOnLastExercise,
                   manager.exerciseQueue.indices.contains(manager.currentIndex + 1) {
                    VStack(spacing: 8) {
                        Text("COMING UP")
                            .font(.caption.bold())
                            .tracking(2)
                            .foregroundStyle(.gray)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .foregroundStyle(.orange)
                            Text(manager.exerciseQueue[manager.currentIndex + 1].name)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                // MARK: - Skip Rest Button
                Button {
                    manager.skipRest()
                } label: {
                    Text("Skip Rest")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var timerProgress: Double {
        guard manager.restTimeRemaining > 0 else { return 0 }
        return Double(manager.restTimeRemaining) / 60.0
    }
    
    private var restTimeString: String {
        let m = manager.restTimeRemaining / 60
        let s = manager.restTimeRemaining % 60
        return m > 0 ? String(format: "%d:%02d", m, s) : "\(s)"
    }
    
    // MARK: - Motivational Quotes
    
    static let quotes: [String] = [
        "\"The pain you feel today will be the strength you feel tomorrow.\"",
        "\"Success isn't always about greatness. It's about consistency.\"",
        "\"The only bad workout is the one that didn't happen.\"",
        "\"Don't limit your challenges. Challenge your limits.\"",
        "\"Strength does not come from the body. It comes from the will.\"",
        "\"Your body can stand almost anything. It's your mind you have to convince.\"",
        "\"The harder the battle, the sweeter the victory.\"",
        "\"Push yourself because no one else is going to do it for you.\"",
        "\"Great things never come from comfort zones.\"",
        "\"The only way to define your limits is by going beyond them.\""
    ]
}

#Preview {
    WorkoutRestScreen(manager: {
        let m = WorkoutSessionManager(preset: Presets().presets[0])
        m.startWorkout()
        return m
    }())
}
