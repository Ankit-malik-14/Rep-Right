//
//  CustomPresetAdditionView.swift
//  Rep_Right
//
//  Created by Mayurakshi Das on 26/04/26.
//

import SwiftUI

// MARK: - CustomPresetAdditionView

struct CustomPresetAdditionView: View {

    // MARK: - Environment / Dependencies

    /// Injected from the environment — the single shared source of truth for custom presets.
    @Environment(CustomPresetsDummyData.self) private var customPresets
    @Environment(Exercises.self) private var allExercises
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    

    //private let allExercises: [Exercise] =

    @State private var presetName: String = ""
    @State private var selectedFocusArea: FocusArea? = nil  // single selection
    @State private var selectedExercises: Set<Exercise> = []
    @FocusState private var isNameFocused: Bool

    //var onDismiss: (() -> Void)?

//    init(
//        exercises: [Exercise] = Exercises().exerciseList,
//        isPresented: Binding<Bool> = false
//        //onDismiss: (() -> Void)? = nil
//    ) {
//        self.allExercises = exercises
//        self.isPresented = isPresented
//        //self.onDismiss = onDismiss
//    }

    // MARK: - Computed

    private var filteredExercises: [Exercise] {
        guard let area = selectedFocusArea else { return [] }
        return allExercises.exerciseList.filter { exercise in
            exercise.targetAreas.contains { rawArea in
                FocusArea.from(targetArea: rawArea) == area
            }
        }
    }

    private var canContinue: Bool {
        !presetName.trimmingCharacters(in: .whitespaces).isEmpty && !selectedExercises.isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    nameSection
                    focusAreaSection
                    if selectedFocusArea != nil {
                        exerciseSection
                    }
                    if canContinue {
                        summarySection
                    }
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("New Preset")
            .navigationBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .bottom) {
                continueButton
            }
        }
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Preset Name", systemImage: "tag.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Image(systemName: "pencil")
                    .foregroundStyle(.orange)
                    .font(.system(size: 16, weight: .medium))

                TextField("e.g. Push Day, Leg Blast…", text: $presetName)
                    .focused($isNameFocused)
                    .font(.body)
                    .submitLabel(.done)
                    .onSubmit { isNameFocused = false }

                if !presetName.isEmpty {
                    Button { presetName = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(14)
            .background(.background, in: RoundedRectangle(cornerRadius: 14))
            .animation(.easeInOut(duration: 0.15), value: presetName.isEmpty)
        }
    }

    // MARK: - Focus Area Section

    private var focusAreaSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Target Area", systemImage: "figure.arms.open")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100), spacing: 10)],
                spacing: 10
            ) {
                ForEach(FocusArea.allCases, id: \.self) { area in
                    let selected = selectedFocusArea == area
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            if selected {
                                // Tap again to deselect
                                selectedFocusArea = nil
                                selectedExercises = []
                            } else {
                                selectedFocusArea = area
                                selectedExercises = []  // reset exercises when switching area
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: area.systemImage)
                                .font(.system(size: 13, weight: .medium))
                            Text(area.rawValue)
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            selected ? Color.orange : Color(.secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .foregroundStyle(selected ? .white : .primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selected ? Color.orange : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(selected ? 1.03 : 1.0)
                    .animation(.spring(duration: 0.2), value: selected)
                }
            }
        }
    }

    // MARK: - Exercise Section

    private var exerciseSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Choose Exercises", systemImage: "dumbbell.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if !selectedExercises.isEmpty {
                    Text("\(selectedExercises.count) selected")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.12), in: Capsule())
                }
            }

            VStack(spacing: 0) {
                ForEach(filteredExercises) { exercise in
                    ExerciseSelectionRow(
                        exercise: exercise,
                        isSelected: selectedExercises.contains(exercise)
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if selectedExercises.contains(exercise) {
                                selectedExercises.remove(exercise)
                            } else {
                                selectedExercises.insert(exercise)
                            }
                        }
                    }
                    if exercise.id != filteredExercises.last?.id {
                        Divider().padding(.leading, 44)
                    }
                }
            }
            .background(.background, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Preset Summary", systemImage: "checklist")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(presetName.trimmingCharacters(in: .whitespaces))
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(1)
                    Spacer()
                    Text("\(selectedExercises.count) exercises")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.12), in: Capsule())
                }

                Divider()

                if let area = selectedFocusArea {
                    Label(area.rawValue, systemImage: area.systemImage)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.orange.opacity(0.1), in: Capsule())
                        .foregroundStyle(.orange)
                }
            }
            .padding(14)
            .background(.background, in: RoundedRectangle(cornerRadius: 14))
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            savePreset()
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Text("Continue")
                    .font(.body.weight(.semibold))
                Image(systemName: "arrow.right")
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                canContinue ? Color.orange : Color(.systemFill),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .foregroundStyle(canContinue ? .white : .secondary)
        }
        .disabled(!canContinue)
        .animation(.easeInOut(duration: 0.2), value: canContinue)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    // MARK: - Save Logic

    private func savePreset() {
        let exercises = Array(selectedExercises)
        let equipments = Array(Set(exercises.flatMap { $0.equipments })).sorted()
        let estTime = max(15, exercises.count * 5)

        let newPreset = Preset(
            name: presetName.trimmingCharacters(in: .whitespaces),
            exercises: exercises,
            isWarmpUp: false,
            scheduledFor: nil,
            estTime: estTime,
            equipments: equipments,
            calories: exercises.reduce(0) { $0 + Int($1.metValue * Double(estTime) / Double(exercises.count)) }
        )

        customPresets.customPresets.append(newPreset)
        for i in customPresets.customPresets{
            print(i.name)
        }
//        onDismiss()
    }
}

// MARK: - ExerciseSelectionRow

private struct ExerciseSelectionRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .orange : .gray)
                    .font(.system(size: 22))
                    .animation(.spring(duration: 0.2), value: isSelected)

                VStack(alignment: .leading, spacing: 3) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)

                    Text(exercise.targetAreas.prefix(3).joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let firstSet = exercise.setData.first {
                    Text("\(firstSet.sets)×\(firstSet.reps)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(.tertiarySystemFill), in: Capsule())
                }
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FocusArea + systemImage

private extension FocusArea {
    var systemImage: String {
        switch self {
        case .shoulder: return "arrow.up.left.and.arrow.up.right"
        case .back:     return "figure.walk"
        case .chest:    return "heart.fill"
        case .arms:     return "figure.strengthtraining.traditional"
        case .core:     return "circle.grid.cross.fill"
        case .legs:     return "figure.run"
        }
    }
}

// MARK: - FlowLayout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows
            .map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }
            .reduce(0) { $0 + $1 + spacing }
        return CGSize(width: proposal.width ?? 0, height: max(0, height - spacing))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var x: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        for subview in subviews {
            let width = subview.sizeThatFits(.unspecified).width
            if x + width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append(subview)
            x += width + spacing
        }
        return rows
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var showSheet = true
    CustomPresetAdditionView(isPresented: $showSheet)
        .environment(CustomPresetsDummyData())
}
