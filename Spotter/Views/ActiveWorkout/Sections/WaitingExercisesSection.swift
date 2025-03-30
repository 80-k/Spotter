//
//  WaitingExercisesSection.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct WaitingExercisesSection: View {
    var viewModel: ActiveWorkoutViewModel
    
    var body: some View {
        let waitingExercises = getWaitingExercises()
        
        if !waitingExercises.isEmpty {
            SectionHeader(
                title: "대기 중인 운동",
                icon: "hourglass",
                color: .orange
            )
            .padding(.horizontal)
            
            // 대기 중인 운동 목록
            LazyVStack(spacing: 12) {
                ForEach(waitingExercises) { exercise in
                    WorkoutExerciseSection(
                        viewModel: viewModel,
                        exercise: exercise,
                        isActive: false
                    )
                    .padding(.horizontal)
                    .opacity(viewModel.isAnotherExerciseActive(exercise) ? 0.7 : 1.0)
                }
            }
        }
    }
    
    // 대기 중인 운동 목록 계산
    private func getWaitingExercises() -> [ExerciseItem] {
        return viewModel.exercises.filter { exercise in
            viewModel.currentActiveExercise?.id != exercise.id &&
            !viewModel.completedExercises.contains { $0.id == exercise.id }
        }
    }
}
