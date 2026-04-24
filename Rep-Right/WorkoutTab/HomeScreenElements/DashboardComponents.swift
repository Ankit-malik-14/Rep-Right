import SwiftUI

struct ReadinessBannerView: View {
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(Exercises.self) private var exercises
    @Environment(WeeklySchedules.self) private var weeklySchedules

    var body: some View {
        let preset = todaysSchedule
        let warnings = preset != nil ? summaryManager.muscleRecoveryStatus(for: preset!, using: exercises.exerciseList) : []
        
        HStack {
            if preset == nil {
                Label("Rest Day - Recover well!", systemImage: "moon.zzz.fill")
                    .foregroundColor(.blue)
            } else if warnings.isEmpty {
                Label("All systems go 💪", systemImage: "checkmark.seal.fill")
                    .foregroundColor(.green)
            } else if warnings.count > (preset!.focousArea.count / 2) {
                Label("Rest recommended", systemImage: "exclamationmark.octagon.fill")
                    .foregroundColor(.red)
            } else {
                Label("Some muscles still recovering", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var todaysSchedule: Preset? {
        let day = Calendar.current.component(.weekday, from: Date())
        let pair = weeklySchedules.schedules.first(where: {$0.key.rawValue == day} )
        return pair?.value
    }
}

struct QuickActionRow: View {
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(Exercises.self) private var exercises
    @State private var showScheduler = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                // Action 1: Recovery Map
                RecoveryMapCard()
                
                // Action 2: Scheduler
                Button(action: {
                    showScheduler = true
                }) {
                    QuickActionCard(title: "Scheduler", icon: "calendar", color: .blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .sheet(isPresented: $showScheduler) {
                SchedulerView()
            }
        }
    }
}

struct RecoveryMapCard: View {
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(Exercises.self) private var exercises
    
    var body: some View {
        VStack(alignment: .leading) {
            Label("Recovery", systemImage: "figure.walk")
                .font(.subheadline.bold())
            
            // Simplified view for the widget
            HStack {
                Circle().fill(Color.green).frame(width: 8, height: 8)
                Text("Legs").font(.caption2)
                Circle().fill(Color.yellow).frame(width: 8, height: 8)
                Text("Chest").font(.caption2)
            }
        }
        .padding()
        .frame(width: 140, height: 80, alignment: .topLeading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Spacer()
            Text(title)
                .font(.subheadline.bold())
        }
        .padding()
        .frame(width: 110, height: 80, alignment: .bottomLeading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SmartRecommendationCard: View {
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(Presets.self) private var presets
    @Environment(Exercises.self) private var exercises
    
    @State private var isVisible = false

    var body: some View {
        if let bestPreset = summaryManager.smartPresetRecommendation(from: presets.presets, using: exercises.exerciseList) {
            VStack(alignment: .leading) {
                Text("Recommended for You")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(bestPreset.name)
                            .font(.title3.bold())
                        Text("Ready to train based on your recovery.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        isVisible = true
                    }
                }
            }
        }
    }
}
