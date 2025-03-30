// WaitingExercisesSection.swift
// 대기 중인 운동 목록 섹션 컴포넌트
// Created by woo on 3/30/25.

import SwiftUI

struct WaitingExercisesSection: View {
    var viewModel: ActiveWorkoutViewModel
    
    var body: some View {
        let waitingExercises = getWaitingExercises()
        
        if !waitingExercises.isEmpty {
            // 이름 변경된 컴포넌트 사용
            WorkoutSectionHeaderView(
                title: "대기 중인 운동",
                icon: "hourglass",
                color: .orange
            )
            .padding(.horizontal)
            
            // 대기 중인 운동 목록
            LazyVStack(spacing: 12) {
                ForEach(waitingExercises) { exercise in
                    // 이름 변경된 컴포넌트 사용
                    ActiveWorkoutExerciseView(
                        viewModel: viewModel,
                        exercise: exercise,
                        isActive: false
                    )
                    .padding(.horizontal)
                    // 여기서 opacity는 modifier이므로 문제없음
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
