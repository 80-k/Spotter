// WorkoutContentView.swift
// 운동 내용을 표시하는 메인 컨텐츠 뷰
// Created by woo on 3/30/25.

import SwiftUI

struct WorkoutContentView: View {
    var viewModel: ActiveWorkoutViewModel
    var onAddExerciseTapped: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 현재 진행 중인 운동 섹션
                ActiveExerciseSection(viewModel: viewModel)
                
                // 대기 중인 운동 목록
                WaitingExercisesSection(viewModel: viewModel)
                
                // 완료된 운동 목록
                CompletedExercisesSection(viewModel: viewModel)
                
                // 운동 추가 버튼 - 이름 변경된 컴포넌트 사용
                WorkoutAddExerciseButton(action: onAddExerciseTapped)
                    .padding(.horizontal)
                    .padding(.vertical, 16)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentActiveExercise != nil)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.restTimerActive)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.completedExercises.count)
        }
    }
}
