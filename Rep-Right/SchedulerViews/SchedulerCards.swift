//
//  SchedulerCards.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-31.
//

import SwiftUI

struct SchedulerCards: View {
    var weekday: Weekday
    var contextPreset: Preset? = nil
    @Environment(WeeklySchedules.self) var weeklySchedules
    @Environment(WorkoutSummaryManager.self) var summaryManager
    @Environment(Exercises.self) var exercises
    @Environment(Presets.self) private var presets
    @Environment(\.dismiss) private var dismiss
    var preset: Preset? {weeklySchedules.schedules[weekday]}
    @State var selectionSheet: Bool = false
    @State var isRest = false
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .center){
                VStack(alignment: .leading){
                    switch weekday {
                    case .sunday:
                        Text("Sunday")
                            .font(.caption).fontWeight(.heavy).foregroundStyle(isRest ? Color.secondary: .orange)
                    case .monday:
                        Text("Monday")
                            .font(.caption).fontWeight(.heavy).foregroundStyle(isRest ? Color.secondary: .orange)
                    case .tuesday:
                        Text("Tuesday")
                            .font(.caption).fontWeight(.heavy).foregroundStyle(isRest ? Color.secondary: .orange)
                    case .wednesday:
                        Text("Wednesday")
                            .font(.caption).fontWeight(.heavy).foregroundStyle(isRest ? Color.secondary: .orange)
                    case .thursday:
                        Text("Thursday")
                            .font(.caption).fontWeight(.heavy).foregroundStyle(isRest ? Color.secondary: .orange)
                    case .friday:
                        Text("Friday")
                            .font(.caption).fontWeight(.heavy).foregroundStyle(isRest ? Color.secondary: .orange)
                    case .saturday:
                        Text("Saturday")
                            .font(.caption).fontWeight(.heavy).foregroundStyle(isRest ? Color.secondary: .orange)
                    }
                    
                    
                    if !isRest{
                        Text(preset?.name ?? "")
                            .font(.title2).bold()
                    }
                    else{
                        Text("Rest Day")
                            .font(.title2).bold().foregroundStyle(.secondary)
                    }
                    
                }
                Spacer()
                Toggle(isOn: $isRest){
                    Text("Rest Day")
                        .font(.headline).bold().foregroundStyle(isRest ? .primary:.secondary)
                }
                    .frame(width: 140)
            }
            if !isRest{
                if preset != nil{
                    HStack{
                        RoundedRectangle(cornerRadius: 13)
                            .frame(width: 58,height: 58)
                            .foregroundStyle(.orange)
                            .opacity(0.4).overlay{
                                Image(systemName: "dumbbell.fill").foregroundStyle(.orange)
                            }
                        VStack(alignment: .leading) {
                            HStack(alignment:.bottom ,spacing: 2){
                                Image(systemName: "flame.fill")
                                Text("\(preset!.calories) Kcal")
                                Text("•")
                                Image(systemName: "clock")
                                Text("\(preset!.estTime) mins")
                            }.font(.caption2).foregroundStyle(.secondary)
                            Text("Includes \(preset!.exercises.map(\.name).joined(separator: ", "))").font(.body).bold().lineLimit(2)
                            
                        }
                        Spacer()
                        VStack{
                            Button(contextPreset != nil ? "Assign" : "Edit"){
                                if let contextPreset = contextPreset {
                                    weeklySchedules.schedules[weekday] = contextPreset
                                    dismiss()
                                } else {
                                    selectionSheet.toggle()
                                }
                            }.buttonStyle(.borderedProminent).tint(.orange)
                                .sheet(isPresented: $selectionSheet) {
                                    PresetSelectionView(weekday: weekday)
                                }
                        }
                    }
                    .padding()
                    .background(.background.secondary,in: RoundedRectangle(cornerRadius: 20))
                }
                else{
                    Button{
                        if let contextPreset = contextPreset {
                            weeklySchedules.schedules[weekday] = contextPreset
                            dismiss()
                        } else {
                            selectionSheet.toggle()
                        }
                    } label: {
                        VStack{
                            ZStack{
                                Circle()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(.background)
                                    .overlay{
                                        Image(systemName: "plus")
                                            .bold()
                                            .foregroundStyle(.orange)
                                        }
                            }
                            Text("Tap to schedule a preset")
                                .foregroundStyle(.secondary)
                        }.padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.background.secondary)
                            .overlay{
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(style: .init(dash: [2]))
                                    .foregroundStyle(.secondary)
                            }
                        )
                        .padding(.top)
                    }
                    .buttonStyle(.plain)
                        .sheet(isPresented: $selectionSheet) {
                            PresetSelectionView(weekday: weekday)
                        }
                }
            }
            else {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Today's Recovery Tips", systemImage: "bolt.heart.fill")
                        .font(.headline.bold())
                        .foregroundStyle(.orange)
                    
                    ForEach(restDayTips(for: weekday), id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text(tip).font(.subheadline)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(style: .init(dash: [2]))
                )
                .foregroundStyle(.secondary)
            }
            
        }.padding().background(.background.secondary, in: RoundedRectangle(cornerRadius: 20))
            .padding(3)
            .onAppear {
                isRest = preset?.isRestDay ?? false
            }
            .onChange(of: preset?.id) { _, _ in
                isRest = preset?.isRestDay ?? false
            }
            .onChange(of: isRest) { _, newValue in
                guard newValue else { return }
                if let recoveryPreset = weeklySchedules.schedules[weekday], recoveryPreset.isRestDay {
                    return
                }
                if let activeRecovery = presets.presets.first(where: { $0.isRestDay }) {
                    weeklySchedules.schedules[weekday] = activeRecovery
                }
            }
    }
    
    func restDayTips(for weekday: Weekday) -> [String] {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterdayRecords = summaryManager.completedExercises.filter { calendar.isDate($0.date, inSameDayAs: yesterday) }
        
        var trainedMuscles: Set<String> = []
        for record in yesterdayRecords {
            if let ex = exercises.exerciseList.first(where: { $0.id == record.exerciseId }) {
                for area in ex.targetAreas {
                    trainedMuscles.insert(area)
                }
            }
        }
        
        var tips = [
            "Hydrate well to flush out metabolic waste.",
            "Aim for 8-9 hours of sleep tonight to maximize recovery."
        ]
        
        if !trainedMuscles.isEmpty {
            let musclesStr = trainedMuscles.prefix(2).joined(separator: " and ")
            tips.insert("Light walking is fine, but avoid heavy loading on your \(musclesStr.lowercased()) today.", at: 0)
        } else {
            tips.insert("A 15-minute mobility flow or stretching session is perfect for today.", at: 0)
        }
        
        return tips
    }
}

#Preview {
    SchedulerCards(weekday: .friday)
        .environment(Presets())
        .environment(WeeklySchedules())
        .environment(WorkoutSummaryManager())
        .environment(Exercises())
}
