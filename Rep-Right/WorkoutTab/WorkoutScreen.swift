//
//  WorkoutScreen.swift
//  Rep-Right
//
//  Created by Mayurakshi Das on 16/03/26.
//

import SwiftUI

struct WorkoutScreen: View {
    @Environment(Exercises.self) var exercises
    @Environment(Presets.self) var preset
    @Environment(CustomPresetsDummyData.self) var customPresets
    @State private var router = WorkoutRouter()
    @State var showScheduler = false
    var body: some View {
        @Bindable var routerBindable = router
        NavigationStack(path: $routerBindable.path){
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading){
                    
//                    ReadinessBannerView()
//                        .padding(.top)
                    ScheduledWorkoutCard()
                    
                    QuickActionRow()
                        .padding(.vertical, 8)
                    
                    
                    
                    SmartRecommendationCard()
                        .padding(.bottom, 8)
                    
                    SmartWeekScheduleCard()
                        .padding(.bottom, 8)
                    
                    // Fetched from DataModel: User's custom presets data model
                    CustomPreset(preset: customPresets)
                        //.padding(.horizontal)
                    
                    // Fetched from DataModel: Main default presets data model
                    DefaultPresets(preset: preset)
                    HStack{
                        NavigationLink(value: WorkoutRoute.exerciseList) {
                            HStack{
                                Text("Exercises")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.black)
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .padding(.top,4)
                                    .tint(.orange)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    ExerciseDisclosedListView()
                }
            }
            // MARK: - Single navigation destination for the entire Workout tab
            .navigationDestination(for: WorkoutRoute.self) { route in
                switch route {
                case .defaultPresetsList:
                    DefaultPresetListView(presets: preset)
                case .customPresetsList:
                    CustomPresetsListView(preset: customPresets)
                case .exerciseList:
                    ExerciseListView()
                case .presetDetail(let p):
                    WorkoutDetailView(preset: p)
                case .exerciseDetail(let e):
                    ExercisesView(exercise: e)
                case .preWorkoutGate(let p):
                    PreWorkoutGateView(preset: p)
                case .activeWorkout(let p):
                    ActiveWorkoutView(preset: p)
                case .profile:
                    ProfileFormView()
                }
            }
            .navigationTitle("Workouts")
            .toolbar{
//                ToolbarItem(placement: .topBarTrailing){
//                    NavigationLink(value: WorkoutRoute.profile) {
//                        Image(systemName: "person.circle.fill")
//                    }
//                }
                ToolbarItem(placement:.topBarTrailing) {
                    Image(systemName: "calendar")
                        .onTapGesture {
                            showScheduler = true
                        }
                }
            
            }
            .sheet(isPresented: $showScheduler) {
                SchedulerView()
            }
            

        }
        .environment(router)
    }
}

#Preview {
    NavigationStack{
        WorkoutScreen()
            .environment(Presets())
            .environment(Exercises())
            .environment(WeeklySchedules())
            .environment(CustomPresetsDummyData())
            .environment(WorkoutSummaryManager())
            .environment(UserProfileModel())
    }
}
