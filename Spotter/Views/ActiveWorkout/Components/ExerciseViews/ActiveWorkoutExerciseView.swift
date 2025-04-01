// ActiveWorkoutExerciseView.swift
// 활성 운동 뷰 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI
import SwiftData

// MARK: - 이 클래스는 ExerciseSetManager.swift로 이동되었습니다
/*
class ExerciseSetManager {
    private let viewModel: ActiveWorkoutViewModel
    private let exercise: ExerciseItem
    
    init(viewModel: ActiveWorkoutViewModel, exercise: ExerciseItem) {
        self.viewModel = viewModel
        self.exercise = exercise
    }
    
    // 세트 로드
    func loadSets() -> [WorkoutSet] {
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
                return [newSet]
            } else {
                return updatedSets
            }
        } else {
            // 이미 세트가 있으면 그대로 사용
            return loadedSets
        }
    }
    
    // 모든 세트 완료 여부 확인
    func areAllSetsCompleted(_ sets: [WorkoutSet]) -> Bool {
        guard !sets.isEmpty else { return false }
        return sets.allSatisfy { $0.isCompleted }
    }
    
    // 일부 세트 완료 여부 확인
    func areSomeSetsCompleted(_ sets: [WorkoutSet]) -> Bool {
        return sets.contains { $0.isCompleted } && !areAllSetsCompleted(sets)
    }
    
    // 운동 상태 계산
    func calculateExerciseStatus(_ sets: [WorkoutSet]) -> ExerciseCompletionStatus {
        if areAllSetsCompleted(sets) {
            return .done
        } else if areSomeSetsCompleted(sets) {
            return .active
        } else {
            return .idle
        }
    }
}
*/

// MARK: - 뷰 확장 (스타일링)
// 이 확장은 ExerciseViewStyles.swift 파일로 이동되어 통합되었습니다
/*
extension View {
    // 운동 컨테이너 스타일 적용
    func exerciseContainerStyle(
        status: ExerciseCompletionStatus,
        isActive: Bool,
        isMinimized: Bool
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(status.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(status.borderColor, lineWidth: 1)
            )
            .cornerRadius(12)
            .contentShape(Rectangle())
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isMinimized)
            .frame(height: isMinimized ? 65 : nil)
    }
}
*/

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
