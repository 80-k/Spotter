//
//  ActiveRestTimerSection.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct ActiveRestTimerSection: View {
    var viewModel: ActiveWorkoutViewModel
    var activeExercise: ExerciseItem
    
    var body: some View {
        RestTimerSectionView(
            exercise: activeExercise,
            remainingTime: viewModel.remainingRestTime,
            totalTime: viewModel.currentActiveSet?.restTime ?? 60
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
