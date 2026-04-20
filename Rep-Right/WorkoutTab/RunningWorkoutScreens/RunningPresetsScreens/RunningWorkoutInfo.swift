/* DEPRECATED: Replaced by WorkoutControlsSheet. This view was part of the old RunningWorkoutView flow.
//
//  RunningWorkoutInfo.swift
//  Rep-Right
//

import SwiftUI
import Observation

struct WorkoutSet: Identifiable{
    let id = UUID()
    var setNumber: Int
    var weight: String
    var reps: String
    var isCompleted: Bool = false
}

struct RunningWorkoutInfo: View {
    @Bindable var workoutState: ActiveWorkoutState
    @State private var sets: [WorkoutSet] = []
    
    var body: some View {
        ScrollView{
            Grid(alignment: .center, horizontalSpacing: 20, verticalSpacing: 12) {
                // Header row
                GridRow {
                    Text("Set")
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                    Text("Weight")
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                    Text("Reps")
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                }
                Divider()
                
                //Dynamic rows
                ForEach($sets){ $workoutSet in
                    GridRow {
                        Text("\(workoutSet.setNumber)")
                            .font(.title3.bold())
                        TextField("kg", text: $workoutSet.weight)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 80)
                        TextField("Reps", text: $workoutSet.reps)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 60)
                    }
                    .font(.title3.bold())
                }
                
                //Add set button
                GridRow{
                    Button{
                        let nextNumber = (sets.count) + 1
                        sets.append(WorkoutSet(setNumber: nextNumber, weight: sets.last?.weight ?? "0", reps: sets.last?.reps ?? "8"))
                    }label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(.background.secondary)
                                .frame(maxWidth: .infinity)
                            Label("Add Set", systemImage: "plus")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundStyle(.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .gridCellColumns(3)
                }
                .padding(.top, 10)
                
                //control
                GridRow{
                    HStack(spacing: 12){
                        ControlButton(title: workoutState.isTimerRunning ? "Pause" : "Play", icon: workoutState.isTimerRunning ? "pause" : "play"){
                            if workoutState.isTimerRunning {
                                workoutState.pauseTimer()
                            } else {
                                workoutState.startTimer()
                            }
                        }
                        ControlButton(title: "Skip", icon: "chevron.right"){
                            if workoutState.isOnLastExercise {
                                workoutState.finishWorkout()
                            } else {
                                workoutState.nextExercise()
                            }
                        }
                        
                        // Show "Finish" on the last exercise, "Next" otherwise
                        if workoutState.isOnLastExercise {
                            Button {
                                workoutState.finishWorkout()
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Finish")
                                }
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .foregroundStyle(.white)
                                .background(Color.green, in: RoundedRectangle(cornerRadius: 8))
                            }
                        } else {
                            ControlButton(title: "Next", icon: "checkmark"){
                                workoutState.nextExercise()
                            }
                        }
                    }
                    .gridCellColumns(3)
                }
            
                //assistance Button
                GridRow{
                    Button {
                        // Action for AI Assistance
                    } label: {
                        HStack{
                            Image(systemName: "camera.viewfinder")
                            Text("Use Assistance")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .gridCellColumns(3)
                }
            }
            .padding()
        }
        .onChange(of: workoutState.currentExerciseIndex) { _, _ in
            loadSetsForCurrentExercise()
        }
        .onAppear {
            loadSetsForCurrentExercise()
        }
    }
    
    private func loadSetsForCurrentExercise() {
        guard let exercise = workoutState.currentExercise else { return }
        self.sets = exercise.setData.enumerated().map { (index, data) in
            WorkoutSet(setNumber: index + 1, weight: "0", reps: "\(data.reps)")
        }
        if self.sets.isEmpty {
             self.sets.append(WorkoutSet(setNumber: 1, weight: "0", reps: "8"))
        }
    }
}

struct ControlButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.background.secondary)
            Button(action: action) {
                HStack {
                    Image(systemName: icon)
                    Text(title)
                }
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
*/
