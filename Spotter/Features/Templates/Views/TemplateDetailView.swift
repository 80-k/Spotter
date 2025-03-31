// TemplateDetailView.swift
// 운동 계획 템플릿 상세 화면 - MVVM 패턴 및 최신 SwiftUI API 적용
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct TemplateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: TemplateDetailViewModel
    
    // 네비게이션 상태 - 뷰에서만 관리되는 UI 상태
    @State private var exerciseSelectorDismissed = false
    
    // 콜백 클로저
    var onStartWorkout: (WorkoutSession) -> Void
    
    init(template: WorkoutTemplate, listViewModel: TemplateListViewModel, onStartWorkout: @escaping (WorkoutSession) -> Void) {
        let vm = TemplateDetailViewModel(
            modelContext: ModelContext(try! ModelContainer(for: ExerciseItem.self, WorkoutTemplate.self, WorkoutSession.self, WorkoutSet.self)),
            template: template,
            listViewModel: listViewModel
        )
        self._viewModel = State(initialValue: vm)
        self.onStartWorkout = onStartWorkout
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            TemplateHeaderView(
                name: viewModel.template.name,
                exerciseCount: viewModel.template.exercises?.count ?? 0
            )
            
            Divider()
                .padding(.top, 4)
            
            // 운동 목록
            ScrollView {
                ExerciseListView(
                    exercises: viewModel.template.exercises ?? [],
                    onAddExercise: {
                        viewModel.isExerciseSelectorPresented = true
                    },
                    onRemoveExercise: { exercise in
                        viewModel.removeExerciseFromTemplate(exercise)
                    },
                    onExerciseTapped: { exercise in
                        viewModel.selectedExercise = exercise
                    }
                )
                
                Spacer(minLength: 100)
            }
            
            // 하단 버튼
            StartWorkoutButtonView(
                isDisabled: viewModel.template.exercises?.isEmpty ?? true,
                onStartWorkout: {
                    if let session = viewModel.startWorkout() {
                        onStartWorkout(session)
                    }
                }
            )
        }
        .navigationTitle("템플릿 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.isEditViewPresented = true
                }) {
                    Label("편집", systemImage: "pencil")
                }
            }
        }
        // 템플릿 편집 시트
        .sheet(isPresented: $viewModel.isEditViewPresented) {
            TemplateEditView(
                template: viewModel.template,
                onSave: { updatedTemplate in
                    viewModel.refreshTemplateData()
                }
            )
        }
        // 운동 선택 화면 네비게이션
        .navigationDestination(isPresented: $viewModel.isExerciseSelectorPresented) {
            ExerciseSelectionView(
                initialSelection: viewModel.template.exercises ?? [],
                onSelectionComplete: { selectedExercises in
                    viewModel.updateExercises(with: selectedExercises)
                    
                    // 네비게이션 스택 관리를 위해 지연 설정
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.isExerciseSelectorPresented = false
                    }
                }
            )
            // 뒤로 가기 시 상태 정리
            .onDisappear {
                if !exerciseSelectorDismissed {
                    exerciseSelectorDismissed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.isExerciseSelectorPresented = false
                        exerciseSelectorDismissed = false
                    }
                }
            }
        }
        .onAppear {
            viewModel.updateModelContext(modelContext)
            viewModel.refreshTemplateData()
        }
    }
} 