// ActiveWorkoutExerciseView.swift
// 활성 운동 뷰 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI
import SwiftData

// 운동 뷰 컴포넌트
struct ActiveWorkoutExerciseView: View {
    var viewModel: ActiveWorkoutViewModel
    let exercise: ExerciseItem
    var isActive: Bool
    var onMoveUp: (() -> Void)? = nil
    var onMoveDown: (() -> Void)? = nil
    
    // 편집 모드 상태 관리
    @State private var isEditMode: Bool = false

    // Use @State to manage the sets directly
    @State private var sets: [WorkoutSet] = []
    
    // 모든 세트가 완료되었는지 확인
    private var areAllSetsCompleted: Bool {
        !sets.isEmpty && sets.allSatisfy { $0.isCompleted }
    }
    
    // 일부 세트만 완료되었는지 확인
    private var areSomeSetsCompleted: Bool {
        sets.contains(where: { $0.isCompleted }) && !areAllSetsCompleted
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 섹션 헤더 - 이름 변경된 컴포넌트 사용
            HStack {
                ActiveExerciseHeaderView(
                    exerciseName: exercise.name,
                    completionStatus: areAllSetsCompleted ? .completed : areSomeSetsCompleted ? .partiallyCompleted : .notCompleted,
                    onRestTimeChange: { time in
                        viewModel.setRestTimeForExercise(exercise, time: time)
                    },
                    onDelete: {
                        viewModel.exerciseToDelete = exercise
                    },
                    onMoveUp: onMoveUp,
                    onMoveDown: onMoveDown,
                    isEditMode: isEditMode,
                    onEditModeToggle: {
                        isEditMode.toggle()
                    }
                )
            }
            .onAppear {
                loadSets()
            }
            .onChange(of: exercise.id) { _, _ in
                loadSets()
            }
            
            // 세트 섹션
            ExerciseSetSection(
                sets: sets,
                isEditMode: isEditMode,
                areAllSetsCompleted: areAllSetsCompleted,
                areSomeSetsCompleted: areSomeSetsCompleted
            )
            
            // 세트 목록 - 컴포넌트로 분리됨
            SetListContainer(
                sets: $sets,
                viewModel: viewModel,
                exercise: exercise,
                isActive: isActive,
                isEditMode: isEditMode
            )
            
            // 컨트롤 버튼 섹션
            ExerciseControlButtonsSection(
                isEditMode: isEditMode,
                viewModel: viewModel,
                exercise: exercise,
                onEditModeToggle: {
                    isEditMode.toggle()
                },
                onSetsUpdate: {
                    loadSets()
                },
                sets: $sets
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(areAllSetsCompleted ? SpotColor.success.opacity(0.08) :
                      isActive ? SpotColor.primary.opacity(0.08) :
                      areSomeSetsCompleted ? SpotColor.warning.opacity(0.08) :
                      Color(.tertiarySystemGroupedBackground))
        )
        // 테두리는 필요한 경우에만 추가
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    areAllSetsCompleted ? SpotColor.success.opacity(0.2) :
                    isActive ? SpotColor.primary.opacity(0.2) :
                    areSomeSetsCompleted ? SpotColor.warning.opacity(0.2) :
                    Color.clear,
                    lineWidth: 1
                )
        )
        .cornerRadius(12)
    }
    
    // 세트 로드 함수
    private func loadSets() {
        print("세트 로드 중... 운동: \(exercise.name)")
        let loadedSets = viewModel.getSetsForExercise(exercise)
        
        if loadedSets.isEmpty {
            // 세트가 없으면 하나 추가 후 다시 로드
            print("세트가 없어 새로 추가합니다.")
            let newSet = viewModel.addSet(for: exercise)
            print("새 세트 추가 완료: \(newSet.id)")
            
            // 세트를 추가한 후 목록 다시 로드
            let updatedSets = viewModel.getSetsForExercise(exercise)
            
            if updatedSets.isEmpty {
                // 여전히 세트가 없다면 로컬 배열에 직접 추가
                print("경고: 세트 추가 후에도 세트 목록이 비어 있습니다. 수동으로 추가합니다.")
                sets = [newSet]
            } else {
                sets = updatedSets
            }
        } else {
            // 이미 세트가 있으면 그대로 사용
            sets = loadedSets
        }
        
        print("로드된 세트 수: \(sets.count)")
    }
}
