// ActiveWorkoutExerciseView.swift
// 활성 운동 뷰 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI
import SwiftData

// 이전에 이 파일에 있던 코드는 다음 파일로 이동되었습니다:
// - ExerciseSetManager 클래스 → ExerciseSetManager.swift
// - View 확장 (스타일링) → ExerciseViewStyles.swift

// MARK: - 운동 뷰 컴포넌트
struct ActiveWorkoutExerciseView: View {
    // MARK: - 속성
    var viewModel: ActiveWorkoutViewModel
    let exercise: ExerciseItem
    var isActive: Bool
    var onMoveUp: (() -> Void)? = nil
    var onMoveDown: (() -> Void)? = nil
    
    // MARK: - 상태
    @State private var isEditMode: Bool = false
    @State private var isMinimized: Bool = false
    @State private var sets: [WorkoutSet] = []
    
    // MARK: - 세트 관리자
    private var setManager: ExerciseSetManagement
    
    // MARK: - 초기화
    init(
        viewModel: ActiveWorkoutViewModel,
        exercise: ExerciseItem,
        isActive: Bool,
        onMoveUp: (() -> Void)? = nil,
        onMoveDown: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.exercise = exercise
        self.isActive = isActive
        self.onMoveUp = onMoveUp
        self.onMoveDown = onMoveDown
        self.setManager = ExerciseSetManagerImpl(viewModel: viewModel, exercise: exercise)
    }
    
    // MARK: - 상태 계산 속성
    private var completionStatus: ExerciseCompletionStatus {
        setManager.calculateExerciseStatus(sets)
    }
    
    // MARK: - 뷰 본문
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 헤더 뷰
            exerciseHeader
            
            // 내용 뷰 (최소화 상태가 아닐 때만)
            if !isMinimized {
                exerciseContent
            }
        }
        .exerciseContainerStyle(
            status: completionStatus,
            isActive: isActive,
            isMinimized: isMinimized
        )
        .onTapGesture {
            if isMinimized {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isMinimized = false
                }
            }
        }
    }
    
    // MARK: - 헤더 영역
    private var exerciseHeader: some View {
        ExerciseHeaderView(
            exercise: exercise,
            isActive: isActive,
            isMinimized: isMinimized,
            viewModel: viewModel,
            onMoveUp: onMoveUp,
            onMoveDown: onMoveDown,
            onToggleMinimized: toggleMinimized,
            completionStatus: completionStatus,
            isEditMode: isEditMode,
            onEditModeToggle: toggleEditMode
        )
        .onAppear {
            refreshSets()
        }
        .onChange(of: exercise.id) { _, _ in
            refreshSets()
        }
    }
    
    // MARK: - 내용 영역
    private var exerciseContent: some View {
        VStack(spacing: 0) {
            // 세트 섹션
            ExerciseSetSection(
                sets: sets,
                isEditMode: isEditMode,
                areAllSetsCompleted: setManager.areAllSetsCompleted(sets),
                areSomeSetsCompleted: setManager.areSomeSetsCompleted(sets)
            )
            
            // 세트 목록
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
                onEditModeToggle: toggleEditMode,
                onSetsUpdate: refreshSets,
                sets: $sets
            )
        }
    }
    
    // MARK: - 상태 토글 메서드
    private func toggleMinimized() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isMinimized.toggle()
        }
    }
    
    private func toggleEditMode() {
        withAnimation {
            isEditMode.toggle()
        }
    }
    
    // MARK: - 세트 관리
    private func refreshSets() {
        sets = setManager.loadSets()
    }
}
