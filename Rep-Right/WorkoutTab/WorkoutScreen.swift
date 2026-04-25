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
                    
                    // Fetched from DataModel: User's custom presets data model
                    CustomPreset(preset: customPresets)
                    
                    // Fetched from DataModel: Main default presets data model
                    DefaultPresets(preset: preset)
                    HStack{
                        Text("Exercises")
                            .font(.title.bold())
                            .padding(.horizontal)
                        Spacer()
                        NavigationLink(value: WorkoutRoute.exerciseList) {
                            Text("See all")
                        }.tint(.orange)
                            .padding(.horizontal)
                    }
                    ExerciseListView()
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
                ToolbarItem(placement: .topBarTrailing){
                    NavigationLink(value: WorkoutRoute.profile) {
                        Image(systemName: "person.circle.fill")
                    }
                }
                ToolbarItem(placement:.topBarLeading) {
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
