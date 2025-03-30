// WorkoutAlertExtensions.swift
// ActiveWorkoutView의 알림창 확장
// Created by woo on 3/30/25.

import SwiftUI

// 운동 관련 알림창 관리 확장
extension View {
    func applyAlerts(
        showCompletionAlert: Binding<Bool>,
        showCancelAlert: Binding<Bool>,
        viewModel: ActiveWorkoutViewModel,
        onWorkoutCompleted: @escaping (WorkoutSession) -> Void,
        onWorkoutCancelled: @escaping () -> Void
    ) -> some View {
        return self
            // 운동 완료 알림
            .alert("운동 완료", isPresented: showCompletionAlert) {
                Button("취소", role: .cancel) { }
                Button("완료", role: .destructive) {
                    let success = viewModel.completeWorkout()
                    if success {
                        onWorkoutCompleted(viewModel.currentSession)
                    } else {
                        onWorkoutCancelled()
                    }
                }
            } message: {
                Text("현재 운동을 완료하시겠습니까?")
            }
            
            // 운동 취소 알림
            .alert("운동 취소", isPresented: showCancelAlert) {
                Button("아니오", role: .cancel) { }
                Button("예", role: .destructive) {
                    LiveActivityManager.shared.endActivity()
                    onWorkoutCancelled()
                }
            } message: {
                Text("정말로 운동을 취소하시겠습니까?\n저장되지 않은 운동 기록은 사라집니다.")
            }
            
            // 운동 삭제 알림
            .alert("운동 삭제", isPresented: exerciseDeleteBinding(viewModel: viewModel)) {
                Button("취소", role: .cancel) {
                    viewModel.exerciseToDelete = nil
                }
                Button("삭제", role: .destructive) {
                    if let exercise = viewModel.exerciseToDelete {
                        viewModel.deleteExerciseFromWorkout(exercise)
                    }
                    viewModel.exerciseToDelete = nil
                }
            } message: {
                if let exercise = viewModel.exerciseToDelete {
                    Text("\(exercise.name) 운동을 정말로 삭제하시겠습니까?\n모든 세트 정보가 함께 삭제됩니다.")
                } else {
                    Text("")
                }
            }
    }
    
    // 운동 삭제 바인딩
    private func exerciseDeleteBinding(viewModel: ActiveWorkoutViewModel) -> Binding<Bool> {
        Binding(
            get: { viewModel.exerciseToDelete != nil },
            set: { if !$0 { viewModel.exerciseToDelete = nil } }
        )
    }
}
