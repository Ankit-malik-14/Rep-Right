//
//  RecommendationEngine.swift
//  Rep_Right
//
//  Created by Jugad on 06/04/26.
//

import Foundation

//@Environment(DummyWorkoutSummaryData) var recentActivity
// from the logs of previous two weeks we will get the data about what targetMuscleGroup has been trained to suggest next preset of targetMuscleGroup that doesn't need 48-72hr recovery.
// if for someday user has only done standalone exercises then it is hard to guess targetMuscleGroup of the exercises because exercises feature smaller segments an exercise trains.
//a recommendation engine to suggest preset, with a enum targetMuscleGroup containig cases back, shoulder, chest, core, arms, legs as general rule of thumb after training a targetMuscleGroup atleast 48-72hr should be given for recovery so I will use the daily summary of previous 7 days, first layer will be to remove targetMuscleGroup trained under 48-72hr then will suggest the according to LRU
