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
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(SpotColor.primary)
                    Text("현재 진행 중")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(SpotColor.primary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // 이름 변경: WorkoutExerciseSection → ActiveWorkoutExerciseView
                ActiveWorkoutExerciseView(
                    viewModel: viewModel,
                    exercise: activeExercise,
                    isActive: true
                )
                .padding(.horizontal, 4)
            }
            .padding(.bottom, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
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
    
    // 편집 모드 상태 관리
    @State private var isEditMode: Bool = false
    
    // 운동의 세트 완료 상태 확인
    private var exerciseSets: [WorkoutSet] {
        return viewModel.getSetsForExercise(exercise)
    }
    
    // 모든 세트가 완료되었는지 확인
    private var areAllSetsCompleted: Bool {
        !exerciseSets.isEmpty && exerciseSets.allSatisfy { $0.isCompleted }
    }
    
    // 일부 세트만 완료되었는지 확인
    private var areSomeSetsCompleted: Bool {
        exerciseSets.contains(where: { $0.isCompleted }) && !areAllSetsCompleted
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
                    }
                )
                
                Spacer()
                
                // 순서 변경 모드 토글 버튼
                Button(action: {
                    isEditMode.toggle()
                }) {
                    Image(systemName: isEditMode ? "checkmark.circle.fill" : "arrow.up.arrow.down.circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isEditMode ? SpotColor.success : SpotColor.primary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(isEditMode ? SpotColor.success.opacity(0.1) : SpotColor.primary.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 8)
            }
            
            // 세트 목록 - 드래그 앤 드롭 기능 추가
            let sets = viewModel.getSetsForExercise(exercise)
            
            // 편집 모드일 때만 이동 가능하도록 설정
            List {
                // 드래그 앤 드롭을 위한 ForEach
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
                    .padding(.vertical, 4)
                    .contentShape(Rectangle()) // 드래그 앤 드롭을 위한 터치 영역 확장
                    .listRowInsets(EdgeInsets()) // 리스트 인덴트 제거
                    .listRowBackground(Color.clear) // 리스트 배경 투명하게 설정
                    .listRowSeparator(.hidden) // 리스트 구분선 숨김
                }
                .onMove { source, destination in
                    viewModel.reorderSets(for: exercise, from: source, to: destination)
                }
            }
            .listStyle(PlainListStyle()) // 기본 리스트 스타일 제거
            .environment(\.editMode, .constant(isEditMode ? .active : .inactive)) // 편집 모드 설정
            .padding(.horizontal, -16) // 리스트 여백 조정
            
            // 세트 추가 버튼 - 편집 모드가 아닐 때만 표시
            if !isEditMode {
                Button(action: {
                    viewModel.addSet(for: exercise)
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("세트 추가")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .foregroundColor(SpotColor.primary)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(SpotColor.primary.opacity(0.08))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .padding(.bottom, 12)
            } else {
                // 편집 모드일 때는 완료 버튼 표시
                Button(action: {
                    isEditMode = false
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                        Text("순서 변경 완료")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .foregroundColor(SpotColor.success)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(SpotColor.success.opacity(0.08))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .padding(.bottom, 12)
            }
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
}
