// WorkoutSelectionView.swift
// 개선된 운동 선택 화면 - 네비게이션 스택 방식, 검색창 위치 변경
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
            selectedExercisesSection
            
            // 검색창 (선택된 운동 섹션 아래로 이동)
            searchBar
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color(.systemBackground))
            
            Divider()
            
            // 등록된 운동 목록
            availableExercisesSection
        }
        .navigationTitle("운동 선택")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
    }
    
    // 선택된 운동 목록 섹션
    private var selectedExercisesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 세션 헤더
            if !selectedExercises.isEmpty {
                Text("선택된 운동")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                // 선택된 운동 목록
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(selectedExercises) { exercise in
                            SelectedExerciseChip(
                                exercise: exercise,
                                onRemove: {
                                    removeFromSelection(exercise)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 50)
            } else {
                Text("운동을 선택해주세요")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
        .background(Color(.systemBackground))
    }
    
    // 검색 바
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("운동 이름 검색", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // 등록된 운동 목록 섹션
    private var availableExercisesSection: some View {
        List {
            // 운동 목록
            ForEach(filteredExercises) { exercise in
                ExerciseSelectionRow(
                    exercise: exercise,
                    isSelected: isExerciseSelected(exercise),
                    onToggle: {
                        toggleExerciseSelection(exercise)
                    }
                )
            }
            
            // 새 운동 추가 버튼
            Button(action: {
                showingAddExercise = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("새 운동 등록하기")
                        .fontWeight(.medium)
                }
            }
            .padding(.vertical, 8)
        }
        .listStyle(PlainListStyle())
        .sheet(isPresented: $showingAddExercise) {
            ExerciseAddView { newExercise in
                // 새 운동이 생성되면 목록 갱신 및 선택
                fetchExercises()
                
                if let newExercise = newExercise {
                    addToSelection(newExercise)
                }
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

// 선택된 운동 칩 컴포넌트
struct SelectedExerciseChip: View {
    let exercise: ExerciseItem
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(exercise.name)
                .font(.subheadline)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// 운동 선택 행 컴포넌트
struct ExerciseSelectionRow: View {
    let exercise: ExerciseItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.headline)
                    Text(exercise.muscleGroup)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 선택 상태 표시
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .imageScale(.large)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}
