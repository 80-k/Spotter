// ActiveExerciseSection.swift
// 현재 진행 중인 운동 섹션 컴포넌트
// Created by woo on 3/30/25.

import SwiftUI

struct ActiveExerciseSection: View {
    var viewModel: ActiveWorkoutViewModel
    
    var body: some View {
        if let activeExercise = viewModel.currentActiveExercise {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundColor(.blue)
                    Text("현재 진행 중")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // 이름 변경: WorkoutExerciseSection → ActiveWorkoutExerciseView
                ActiveWorkoutExerciseView(
                    viewModel: viewModel,
                    exercise: activeExercise,
                    isActive: true
                )
                .padding(.horizontal)
            }
            .padding(.bottom, 12)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)
            .transition(.opacity.combined(with: .scale))
        }
    }
}

// 이름 변경: WorkoutExerciseSection → ActiveWorkoutExerciseView
struct ActiveWorkoutExerciseView: View {
    var viewModel: ActiveWorkoutViewModel
    let exercise: ExerciseItem
    var isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 섹션 헤더 - 이름 변경된 컴포넌트 사용
            ActiveExerciseHeaderView(
                exerciseName: exercise.name,
                onRestTimeChange: { time in
                    viewModel.setRestTimeForExercise(exercise, time: time)
                },
                onDelete: {
                    viewModel.exerciseToDelete = exercise
                }
            )
            
            // 세트 목록
            let sets = viewModel.getSetsForExercise(exercise)
            ForEach(sets.indices, id: \.self) { index in
                let set = sets[index]
                
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
                .padding(.vertical, 2)
            }
            
            // 세트 추가 버튼
            Button(action: {
                viewModel.addSet(for: exercise)
            }) {
                HStack {
                    Spacer()
                    Text("세트 추가")
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(isActive ? Color.blue.opacity(0.05) : Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}
