// WorkoutSelectionView.swift
// 운동 선택 화면 - 메인 컨테이너 뷰
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct WorkoutSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // 검색어 상태
    @State private var searchText = ""
    
    // 모든 등록된 운동 목록
    @State private var availableExercises: [ExerciseItem] = []
    
    // 현재 선택된 운동 목록
    @State private var selectedExercises: [ExerciseItem] = []
    
    // 새 운동 추가 시트 표시 여부
    @State private var showingAddExercise = false
    
    // 완료 시 콜백 함수
    var onSelectionComplete: ([ExerciseItem]) -> Void
    
    // 초기 선택된 운동 목록 (편집 시)
    var initialSelection: [ExerciseItem] = []
    
    init(initialSelection: [ExerciseItem] = [], onSelectionComplete: @escaping ([ExerciseItem]) -> Void) {
        self.initialSelection = initialSelection
        self.onSelectionComplete = onSelectionComplete
        self._selectedExercises = State(initialValue: initialSelection)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 선택된 운동 목록 섹션
            SelectedExercisesSection(
                selectedExercises: $selectedExercises,
                onRemoveExercise: removeFromSelection
            )
            
            // 검색창
            SearchBarView(searchText: $searchText)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color(.systemBackground))
            
            Divider()
            
            // 등록된 운동 목록
            ExerciseSelectionListView(
                exercises: filteredExercises,
                selectedExercises: selectedExercises,
                onToggleSelection: toggleExerciseSelection,
                onAddNewExercise: { showingAddExercise = true }
            )
        }
        .navigationTitle("운동 선택")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 취소 버튼
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") {
                    dismiss()
                }
            }
            
            // 확인 버튼
            ToolbarItem(placement: .confirmationAction) {
                Button("확인") {
                    onSelectionComplete(selectedExercises)
                    dismiss()
                }
                .disabled(selectedExercises.isEmpty)
            }
        }
        .onAppear {
            fetchExercises()
        }
        .sheet(isPresented: $showingAddExercise) {
            ExerciseAddView { newExercise in
                if let newExercise = newExercise {
                    addToSelection(newExercise)
                }
                fetchExercises()
            }
        }
    }
    
    // 필터링된 운동 목록 (검색어 적용)
    private var filteredExercises: [ExerciseItem] {
        if searchText.isEmpty {
            return availableExercises
        } else {
            return availableExercises.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.muscleGroup.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // 운동이 현재 선택되었는지 확인
    private func isExerciseSelected(_ exercise: ExerciseItem) -> Bool {
        return selectedExercises.contains { $0.id == exercise.id }
    }
    
    // 운동 선택 토글
    private func toggleExerciseSelection(_ exercise: ExerciseItem) {
        if isExerciseSelected(exercise) {
            removeFromSelection(exercise)
        } else {
            addToSelection(exercise)
        }
    }
    
    // 선택 목록에 운동 추가
    private func addToSelection(_ exercise: ExerciseItem) {
        // 이미 선택되어 있지 않은 경우에만 추가
        if !isExerciseSelected(exercise) {
            selectedExercises.append(exercise)
            
            // 진동 피드백 (추가)
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif
        }
    }
    
    // 선택 목록에서 운동 제거
    private func removeFromSelection(_ exercise: ExerciseItem) {
        selectedExercises.removeAll { $0.id == exercise.id }
        
        // 진동 피드백 (제거)
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    // 모든 운동 목록 가져오기
    private func fetchExercises() {
        do {
            let descriptor = FetchDescriptor<ExerciseItem>(sortBy: [SortDescriptor(\.name)])
            availableExercises = try modelContext.fetch(descriptor)
        } catch {
            print("운동 목록을 가져오는 중 오류 발생: \(error)")
        }
    }
}

// MARK: - 미리보기

#Preview {
    NavigationStack {
        WorkoutSelectionView(
            initialSelection: [],
            onSelectionComplete: { _ in }
        )
        .modelContainer(for: [ExerciseItem.self], inMemory: true)
    }
}
