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
    @Environment(WeeklySchedules.self) var weeklySchedules
    @Environment(WorkoutSummaryManager.self) var summaryManager
    @Environment(UserProfileModel.self) var userProfile

    @State private var router = WorkoutRouter()
    @State private var viewModel: WorkoutHomeViewModel?
    @State private var customPresetsViewModel: CustomPresetsViewModel?
    @State var showScheduler = false
    
    var body: some View {
        @Bindable var routerBindable = router
        NavigationStack(path: $routerBindable.path){
            Group {
                if let viewModel = viewModel, let customPresetsViewModel = customPresetsViewModel {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading){
                            ScheduledWorkoutCard()
                            
                            QuickActionRow()
                                .padding(.vertical, 8)
                            
                            SmartRecommendationCard()
                                .padding(.bottom, 8)
                            
                            SmartWeekScheduleCard()
                                .padding(.bottom, 8)
                            
                            // Fetched from DataModel: User's custom presets data model
                            CustomPreset()
                            
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
                    .environment(viewModel)
                    .environment(customPresetsViewModel)
                    // MARK: - Single navigation destination for the entire Workout tab
                    .navigationDestination(for: WorkoutRoute.self) { route in
                        switch route {
                        case .defaultPresetsList:
                            DefaultPresetListView(presets: preset)
                        case .customPresetsList:
                            CustomPresetsListView()
                                .environment(customPresetsViewModel)
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
                } else {
                    Color.clear
                }
            }
            .onAppear {
                if viewModel == nil {
                    let vm = WorkoutHomeViewModel(
                        presets: preset,
                        exercises: exercises,
                        weeklySchedules: weeklySchedules,
                        summaryManager: summaryManager,
                        userProfile: userProfile
                    )
                    vm.seedSuggestedWorkoutIfNeeded()
                    viewModel = vm
                }
                if customPresetsViewModel == nil {
                    customPresetsViewModel = CustomPresetsViewModel(
                        customPresetsData: customPresets,
                        exercises: exercises
                    )
                }
            }
            .navigationTitle("Workouts")
            .toolbar{
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
