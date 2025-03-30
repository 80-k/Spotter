//
//  WorkoutExerciseSection.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI
import SwiftData

struct WorkoutExerciseSection: View {
    var viewModel: ActiveWorkoutViewModel
    let exercise: ExerciseItem
    var isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 섹션 헤더
            WorkoutExerciseHeader(
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
