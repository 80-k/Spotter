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
    var onMoveUp: (() -> Void)? = nil
    var onMoveDown: (() -> Void)? = nil
    
    @State private var isMinimized: Bool = false
    
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
                },
                onMoveUp: onMoveUp,
                onMoveDown: onMoveDown,
                onToggleMinimize: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isMinimized.toggle()
                    }
                },
                isMinimized: isMinimized
            )
            
            // 세트 목록 - 최소화 상태일 때는 표시하지 않음
            if !isMinimized {
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
                    .transition(.move(edge: .top).combined(with: .opacity))
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
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(isActive ? Color.blue.opacity(0.05) : Color.gray.opacity(0.05))
        .cornerRadius(8)
        // 높이 애니메이션 적용
        .contentShape(Rectangle())
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isMinimized)
        // 최소화 상태에 따라 섹션 높이 조정
        .frame(height: isMinimized ? 65 : nil)
        // 탭 이벤트를 헤더로 위임
        .onTapGesture {
            if isMinimized {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isMinimized = false
                }
            }
        }
    }
}

// 프리뷰 추가
#Preview {
    VStack {
        Text("운동 섹션 미리보기")
            .font(.headline)
            .padding()
        
        // 프리뷰를 위한 더미 데이터
        let dummyViewModel = ActiveWorkoutViewModel.previewMock()
        let dummyExercise = ExerciseItem(name: "벤치 프레스", muscleGroup: "가슴")
        
        WorkoutExerciseSection(
            viewModel: dummyViewModel,
            exercise: dummyExercise,
            isActive: true
        )
        .padding()
    }
}
