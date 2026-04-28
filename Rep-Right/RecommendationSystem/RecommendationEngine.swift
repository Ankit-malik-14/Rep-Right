//
//  RecommendationEngine.swift
//  Rep_Right
//
//  Created by Jugad on 06/04/26.
//

import Foundation

//a recommendation engine to suggest preset, with a enum targetMuscleGroup containig cases back, shoulder, chest, core, arms, legs as general rule of thumb after training a targetMuscleGroup atleast 48hr should be given for recovery when user has trained it more than 6 time or has performed 6 exercises targeting the muscle group, so using the daily summary of previous 7 days, first layer will be to remove targetMuscleGroup trained under 48hr then will recommend preset according to LRU type algo.

//@Environment(DummyWorkoutSummaryData) var recentActivity
// from the logs of previous two weeks we will get the data about what targetMuscleGroup has been trained to suggest next preset of targetMuscleGroup that doesn't need 48-72hr recovery.
// if for someday user has only done standalone exercises then it is hard to guess targetMuscleGroup of the exercises because exercises feature smaller segments an exercise trains. To solve this specific problem we can try to map these smaller segments to their relative targetMuscleGroup.

