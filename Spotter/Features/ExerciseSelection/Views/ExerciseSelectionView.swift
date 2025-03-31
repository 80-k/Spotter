// ExerciseSelectionView.swift
// 운동 선택 화면 - MVVM 패턴 및 최신 SwiftUI API 적용
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: ExerciseSelectionViewModel
    @State private var showAddExerciseSheet = false
    
    // 완료 시 콜백 함수
    var onSelectionComplete: ([ExerciseItem]) -> Void
    
    init(initialSelection: [ExerciseItem] = [], onSelectionComplete: @escaping ([ExerciseItem]) -> Void) {
        // ModelContext는 생성자에서 초기화할 수 없으므로 나중에 onAppear에서 modelContext로 대체
        let vm = ExerciseSelectionViewModel(
            modelContext: ModelContext(try! ModelContainer(for: ExerciseItem.self, WorkoutTemplate.self, WorkoutSession.self, WorkoutSet.self)),
            initialSelection: initialSelection
        )
        self._viewModel = State(initialValue: vm)
        self.onSelectionComplete = onSelectionComplete
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 선택된 운동 목록 섹션
            SelectedExercisesSection(
                selectedExercises: viewModel.selectedExercises,
                onRemoveExercise: { exercise in
                    viewModel.removeFromSelection(exercise)
                }
            )
            
            // 검색창 및 필터
            SearchBarView(
                searchText: $viewModel.searchText,
                placeholder: "운동 이름 또는 근육 그룹 검색"
            )
            .padding(.vertical, 8)
            .padding(.horizontal)
            
            // 카테고리 필터 (가로 스크롤)
            CategoryFilterView(
                categories: viewModel.availableCategories,
                selectedCategory: $viewModel.selectedCategory
            )
            .padding(.bottom, 8)
            
            Divider()
            
            // 운동 목록
            Group {
                if viewModel.isLoading {
                    ProgressView("운동 목록 로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredExercises.isEmpty {
                    emptyStateView
                } else {
                    exerciseList
                }
            }
        }
        .navigationTitle("운동 선택")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("추가") {
                    showAddExerciseSheet = true
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("확인") {
                    onSelectionComplete(viewModel.selectedExercises)
                    dismiss()
                }
                .disabled(viewModel.selectedExercises.isEmpty)
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showAddExerciseSheet) {
            ExerciseAddView { newExercise in
                if let newExercise = newExercise {
                    viewModel.addToSelection(newExercise)
                }
                viewModel.fetchExercises()
            }
        }
        .onAppear {
            // 환경에서 제공된 modelContext 사용
            viewModel.updateModelContext(modelContext)
            viewModel.fetchExercises()
        }
    }
    
    // 운동 목록 뷰
    private var exerciseList: some View {
        List {
            ForEach(viewModel.filteredExercises) { exercise in
                ExerciseSelectionRow(
                    exercise: exercise,
                    isSelected: viewModel.isExerciseSelected(exercise),
                    onToggle: {
                        viewModel.toggleExerciseSelection(exercise)
                    }
                )
            }
        }
        .listStyle(.plain)
    }
    
    // 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            if viewModel.availableExercises.isEmpty {
                // 운동이 하나도 없는 경우
                EmptyStateView(
                    icon: "dumbbell.fill",
                    title: "등록된 운동이 없습니다",
                    message: "새 운동을 등록해보세요",
                    buttonTitle: "새 운동 추가하기",
                    buttonIcon: "plus.circle.fill",
                    action: { showAddExerciseSheet = true }
                )
            } else if !viewModel.searchText.isEmpty {
                // 검색 결과가 없는 경우
                SearchResultView(
                    searchText: viewModel.searchText,
                    onAddExercise: { showAddExerciseSheet = true }
                )
            } else if viewModel.selectedCategory != nil {
                // 선택된 카테고리에 운동이 없는 경우
                CategoryEmptyView(
                    categoryName: viewModel.selectedCategory!,
                    onAddExercise: { showAddExerciseSheet = true }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 선택된 운동 목록 섹션

struct SelectedExercisesSection: View {
    let selectedExercises: [ExerciseItem]
    let onRemoveExercise: (ExerciseItem) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(selectedExercises) { exercise in
                    SelectedExerciseChip(
                        name: exercise.name,
                        onRemove: {
                            onRemoveExercise(exercise)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .frame(height: selectedExercises.isEmpty ? 0 : 50)
        }
        .frame(height: selectedExercises.isEmpty ? 0 : 50)
        .opacity(selectedExercises.isEmpty ? 0 : 1)
        .animation(.easeInOut(duration: 0.2), value: selectedExercises.isEmpty)
    }
}

// MARK: - 카테고리 필터 뷰

struct CategoryFilterView: View {
    let categories: [String]
    @Binding var selectedCategory: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 전체 카테고리 버튼
                CategoryButton(
                    name: "전체",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                // 각 카테고리 버튼
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        name: category,
                        isSelected: selectedCategory == category,
                        action: {
                            if selectedCategory == category {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// 카테고리 버튼
struct CategoryButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(.footnote, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.15))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - 빈 운동 뷰

/* 파일 분리를 위해 주석 처리
struct EmptyExerciseView: View {
    let onAddExercise: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.4))
            
            Text("등록된 운동이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("새 운동을 등록해보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onAddExercise) {
                Label("새 운동 추가하기", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 250)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}
*/

// 임시 ExerciseAddView 정의
/*
struct ExerciseAddView: View {
    let onComplete: (ExerciseItem?) -> Void
    
    @State private var name = ""
    @State private var muscleGroup = "가슴"
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("운동 정보")) {
                    TextField("운동 이름", text: $name)
                    
                    Picker("근육 그룹", selection: $muscleGroup) {
                        Text("가슴").tag("가슴")
                        Text("등").tag("등")
                        Text("하체").tag("하체")
                        Text("어깨").tag("어깨")
                        Text("팔").tag("팔")
                    }
                }
            }
            .navigationTitle("운동 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        onComplete(nil)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        let newExercise = ExerciseItem(name: name, muscleGroup: muscleGroup)
                        onComplete(newExercise)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
*/

#Preview {
    NavigationStack {
        ExerciseSelectionView(
            initialSelection: [],
            onSelectionComplete: { _ in }
        )
    }
} 
