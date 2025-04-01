// StaticSetListView.swift
// 일반 모드의 정적 세트 목록 뷰 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI

// 일반 모드에서 사용하는 정적 세트 목록 뷰
struct StaticSetListView: View {
    var sets: [WorkoutSet]
    var viewModel: ActiveWorkoutViewModel
    var exercise: ExerciseItem
    var isActive: Bool
    
    var body: some View {
        LazyVStack(spacing: 1) {
            ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                ExerciseSetRowView(
                    set: set,
                    setNumber: index + 1,
                    onWeightChanged: { weight in
                        viewModel.updateSet(set, weight: weight)
                    },
                    onRepsChanged: { reps in
                        viewModel.updateSet(set, reps: reps)
                    },
                    onCompleteToggle: {
                        viewModel.toggleSetCompletion(set)
                    },
                    disableCompleteButton: !isActive && viewModel.isAnotherExerciseActive(exercise)
                )
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(index % 2 == 0 ? Color(.systemBackground).opacity(0.4) : Color.clear)
                .contentShape(Rectangle())
                .overlay(
                    Divider()
                        .opacity(index < sets.count - 1 ? 1 : 0)
                        .padding(.horizontal, 10),
                    alignment: .bottom
                )
            }
        }
    }
}
