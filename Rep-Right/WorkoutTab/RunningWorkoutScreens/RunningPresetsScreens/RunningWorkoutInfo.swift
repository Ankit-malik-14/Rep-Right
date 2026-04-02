//
//  RunningWorkoutInfo.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 19/03/26.
//

import SwiftUI
import Observation
struct WorkoutSet: Identifiable{
    let id = UUID()
    var setNumber: Int
    var weight: String
    var reps: String
}
@Observable
class WorkoutSession{
    //local copy for current session
    var sets: [WorkoutSet] = [
        WorkoutSet(setNumber: 1, weight: "80", reps: "8"),
        WorkoutSet(setNumber: 2, weight: "80", reps: "8"),
        WorkoutSet(setNumber: 3, weight: "80", reps: "8"),
    ]
    func addSet(){
        let nextNumber = (sets.last?.setNumber ?? 0)+1
        let lastWeight = sets.last?.weight ?? "0"
        let lastReps = sets.last?.reps ?? "0"
        sets.append(WorkoutSet(setNumber: nextNumber, weight: lastWeight, reps: lastReps))
    }
}
struct RunningWorkoutInfo: View {
    @State private var session = WorkoutSession()
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
                ForEach($session.sets){ $workoutSet in
                    GridRow {
                        Text("\(workoutSet.setNumber)")
                            .font(.title3.bold())
                        TextField("kg", text: $workoutSet.weight)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .frame(width: 80)
                        TextField("Reps", text: $workoutSet.reps)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .frame(width: 60)
                    }
                    .font(.title3.bold())
                }
                
                //Add set button
                GridRow{
                    Button{
                        session.addSet()
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
                        ControlButton(title: "Pause", icon: "pause"){}
                        ControlButton(title: "Skip", icon: "chevron.right"){}
                        ControlButton(title: "Finish", icon: "checkmark"){}
                    }
                    .gridCellColumns(3)
                }
                .padding(.top, 20)
            
                //assistance Button
                GridRow{
                    Button {
                        //
                    } label: {
                        Label("Use Assistance", systemImage: "camera.viewfinder")
                            .frame(maxWidth: .infinity, maxHeight: 800)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .gridCellColumns(3)
                }
            }
            .padding()
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
            }}
    }
}
#Preview {
    RunningWorkoutInfo()
}
