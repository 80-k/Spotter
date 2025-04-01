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
                ForEach(waitingExercises.indices, id: \.self) { index in
                    let exercise = waitingExercises[index]
                    // 이름 변경된 컴포넌트 사용
                    ActiveWorkoutExerciseView(
                        viewModel: viewModel,
                        exercise: exercise,
                        isActive: false,
                        onMoveUp: index > 0 ? {
                            moveExercise(from: index, to: index - 1)
                        } : nil,
                        onMoveDown: index < waitingExercises.count - 1 ? {
                            moveExercise(from: index, to: index + 1)
                        } : nil
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
    
    // 운동 순서 이동 메서드 추가
    private func moveExercise(from source: Int, to destination: Int) {
        let waitingExercises = getWaitingExercises()
        guard source >= 0, source < waitingExercises.count,
              destination >= 0, destination < waitingExercises.count,
              source != destination else {
            return
        }
        
        // 실제 운동 순서 변경 로직을 구현합니다
        // 해당 ViewModel에 관련 메서드가 없으므로 여기서는 UI 업데이트만 가능합니다
        // 실제 구현에서는 ViewModel에 관련 메서드를 추가해야 합니다
        viewModel.exercises.swapAt(
            viewModel.exercises.firstIndex(of: waitingExercises[source])!,
            viewModel.exercises.firstIndex(of: waitingExercises[destination])!
        )
    }
}
