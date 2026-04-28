import SwiftUI
import Charts

struct ReadinessBannerView: View {
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(Exercises.self) private var exercises
    @Environment(WeeklySchedules.self) private var weeklySchedules

    var body: some View {
        if summaryManager.completedExercises.isEmpty {
            HStack {
                Label("Fresh start today - any preset fits", systemImage: "sparkles")
                    .foregroundColor(.green)
                Spacer()
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        } else {
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
    }

    private var todaysSchedule: Preset? {
        let day = Calendar.current.component(.weekday, from: Date())
        let pair = weeklySchedules.schedules.first(where: { $0.key.rawValue == day })
        return pair?.value
    }
}

struct QuickActionRow: View {
    var body: some View {
        RecoveryMapCard()
    }
}

struct RecoveryMapCard: View {
    @Environment(WorkoutSummaryManager.self) private var summaryManager
    @Environment(Exercises.self) private var exercises
    @Environment(Presets.self) private var presets

    private let focusAreaColors: [String: Color] = [
        FocusArea.back.rawValue: Color(red: 22/255, green: 176/255, blue: 221/255),
        FocusArea.chest.rawValue: Color(red: 228/255, green: 59/255, blue: 55/255),
        FocusArea.legs.rawValue: Color(red: 104/255, green: 199/255, blue: 79/255),
        FocusArea.core.rawValue: Color(red: 247/255, green: 188/255, blue: 36/255),
        FocusArea.shoulder.rawValue: Color(red: 253/255, green: 147/255, blue: 29/255),
        FocusArea.arms.rawValue: Color(red: 160/255, green: 90/255, blue: 220/255)
    ]

    var body: some View {
        let insights = summaryManager.focusAreaLoadInsights(using: exercises.exerciseList)
        let chartData = summaryManager.weeklyFocusAreaChartData(using: exercises.exerciseList)
        let activeChartData = chartData.filter { $0.value > 0 }
        let totalTracked = chartData.reduce(0.0) { $0 + $1.value }

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Recovery Map", systemImage: "figure.strengthtraining.traditional")
                        .font(.subheadline.bold())
                    Text(summaryManager.completedExercises.isEmpty ? "All six focus areas are fresh." : "Weekly exercise load by focus area.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if summaryManager.completedExercises.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("No load yet", systemImage: "bolt.heart")
                        .font(.footnote.bold())
                        .foregroundStyle(.green)
                    Text("Start any preset. Shoulder, back, chest, arms, core, and legs are all fresh right now.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Chart(activeChartData, id: \.category) { item in
                        SectorMark(
                            angle: .value("Exercises", item.value),
                            innerRadius: .ratio(0.7),
                            angularInset: 2.0
                        )
                        .foregroundStyle(by: .value("Focus Area", item.category))
                        .cornerRadius(5)
                    }
                    .chartForegroundStyleScale(
                        domain: activeChartData.map { $0.category },
                        range: activeChartData.map { focusAreaColors[$0.category] ?? .gray }
                    )
                    .chartLegend(position: .bottom, alignment: .center)
                    .frame(height: 250)
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            if let plotFrame = chartProxy.plotFrame {
                                let frame = geometry[plotFrame]
                                VStack(spacing: 4) {
                                    Text("Total")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(Int(totalTracked), format: .number)
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                }
                                .position(x: frame.midX, y: frame.midY)
                            }
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(insights) { insight in
                            FocusAreaCounterCard(
                                insight: insight,
                                color: focusAreaColors[insight.focusArea.rawValue] ?? .gray
                            )
                        }
                    }

                    Text(overallRecommendation(for: insights))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding(16)
        //.frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private func overallRecommendation(for insights: [FocusAreaLoadInsight]) -> String {
        let overloaded = insights.filter { $0.status == .overtrained }.map(\.focusArea.rawValue)
        let onTrack = insights.filter { $0.status == .onTrack }.map(\.focusArea.rawValue)
        let sortedByLoad = insights.sorted {
            if $0.weeklyExercises != $1.weeklyExercises {
                return $0.weeklyExercises < $1.weeklyExercises
            }
            return $0.focusArea.rawValue < $1.focusArea.rawValue
        }

        if !overloaded.isEmpty {
            return "\(formattedList(overloaded)) are above the weekly 12-exercise limit. Ease off and let them recover."
        }

        if onTrack.count >= 2 {
            return "\(formattedList(onTrack)) are right in the 10-12 exercise sweet spot. Keep the rest rotating around them."
        }

        if let weakestFocus = sortedByLoad.first {
            let presetText = recommendedPresetText(for: weakestFocus.focusArea)
            return "Your \(weakestFocus.focusArea.rawValue.lowercased()) count is \(weakestFocus.weeklyExercises). You should do \(weakestFocus.focusArea.rawValue.lowercased()) exercises with \(presetText)."
        }

        return "Your weekly volume is balanced. Keep rotating focus areas instead of stacking the same one again."
    }

    private func recommendedPresetText(for focusArea: FocusArea) -> String {
        let matchingPreset = presets.presets.first { preset in
            preset.exercises.contains { $0.primaryFocusArea == focusArea }
        }

        if let matchingPreset {
            return "the \"\(matchingPreset.name)\" preset"
        }

        return "a preset containing \(focusArea.rawValue.lowercased()) exercises"
    }

    private func formattedList(_ values: [String]) -> String {
        switch values.count {
        case 0:
            return "No focus areas"
        case 1:
            return values[0]
        case 2:
            return values.joined(separator: " and ")
        default:
            return values.dropLast().joined(separator: ", ") + ", and " + (values.last ?? "")
        }
    }
}

private struct FocusAreaCounterCard: View {
    let insight: FocusAreaLoadInsight
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(insight.focusArea.rawValue)
                    .font(.caption.bold())
                Spacer()
                Text("\(insight.weeklyExercises)/12")
                    .font(.caption.bold())
            }

            Text(insight.recommendation)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
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
    @Environment(WeeklySchedules.self) private var weeklySchedules

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
                        Text(recommendationText(for: bestPreset))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    NavigationLink(value: WorkoutRoute.presetDetail(bestPreset)){
                        Image(systemName: "chevron.right.circle.fill")
                            .foregroundColor(.orange)
                            .font(.title)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .onAppear {
                    seedSuggestedWorkoutIfNeeded(with: bestPreset)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        isVisible = true
                    }
                }
            }

        }
    }

    private func recommendationText(for preset: Preset) -> String {
        if summaryManager.completedExercises.isEmpty {
            return "Your target muscles are fresh. Start with this preset to build your first training week."
        }

        let warnings = summaryManager.muscleRecoveryStatus(for: preset, using: exercises.exerciseList)
        if warnings.isEmpty {
            return "Ready to train based on your recovery."
        }

        return "Best match right now with the lightest recovery overlap."
    }

    private func seedSuggestedWorkoutIfNeeded(with preset: Preset) {
        guard summaryManager.completedExercises.isEmpty else { return }
        guard let today = Weekday(rawValue: Calendar.current.component(.weekday, from: Date())) else { return }
        guard weeklySchedules.schedules[today] == nil else { return }

        var scheduledPreset = preset
        scheduledPreset.scheduledFor = today
        weeklySchedules.schedules[today] = scheduledPreset
    }
}
