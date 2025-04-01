// WorkoutTemplateDetailView.swift
// 운동 계획 템플릿 상세 화면 - 코어 컨테이너 컴포넌트
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct WorkoutTemplateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var template: WorkoutTemplate
    @State private var showingEditSheet = false
    @State private var selectedExercise: ExerciseItem? = nil
    @State private var showExerciseSelector = false
    
    
    // 특정 운동 제거
    private func removeExercise(_ exercise: ExerciseItem) {
        template.removeExercise(exercise)
        viewModel.updateTemplate(template)
        refreshTemplateData()
    }

    // 템플릿 데이터 새로고침 (DB에서 최신 상태 가져오기)
    private func refreshTemplateData() {
        viewModel.fetchTemplates()
        
        if let updatedTemplate = viewModel.templates.first(where: { $0.id == template.id }) {
            template = updatedTemplate
        }
    }

    // 선택된 운동 목록으로 업데이트
    private func updateExercises(with exercises: [ExerciseItem]) {
        // 기존 운동 목록을 새로운 목록으로 대체
        template.exerciseItems = []
        
        for exercise in exercises {
            template.addExercise(exercise)
        }
        
        viewModel.updateTemplate(template)
        refreshTemplateData()
    }
    
    var viewModel: WorkoutTemplateListViewModel
    var onStartWorkout: (WorkoutSession) -> Void
    
    init(template: WorkoutTemplate, viewModel: WorkoutTemplateListViewModel, onStartWorkout: @escaping (WorkoutSession) -> Void) {
        self._template = State(initialValue: template)
        self.viewModel = viewModel
        self.onStartWorkout = onStartWorkout
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top header
            TemplateHeaderView(
                name: template.name,
                exerciseCount: template.exerciseItems?.count ?? 0
            )
            
            Divider()
                .padding(.top, 4)
            
            // Exercise list
            ScrollView {
                ExerciseListView(
                    exercises: template.exerciseItems ?? [],
                    onAddExercise: {
                        showExerciseSelector = true
                    },
                    onRemoveExercise: { exercise in
                        removeExercise(exercise)
                    },
                    onExerciseTapped: { exercise in
                        selectedExercise = exercise
                    }
                )
                
                Spacer(minLength: 100)
            }
            
            // Bottom button
            StartWorkoutButtonView(
                isDisabled: template.exerciseItems?.isEmpty ?? true,
                onStartWorkout: {
                    let session = viewModel.startWorkout(with: template)
                    onStartWorkout(session)
                    dismiss()
                }
            )
        }
        .navigationTitle("템플릿 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("템플릿 수정", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        // 템플릿 삭제 로직
                        viewModel.deleteTemplate(template)
                        dismiss()
                    }) {
                        Label("템플릿 삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .padding(8)
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("닫기") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            WorkoutTemplateEditView(viewModel: viewModel, template: template)
        }
        .sheet(item: $selectedExercise) { exercise in
            NavigationStack {
                ExerciseDetailView(exercise: exercise)
            }
        }
        .sheet(isPresented: $showExerciseSelector) {
            NavigationStack {
                WorkoutSelectionView(
                    initialSelection: template.exerciseItems ?? []
                ) { selectedExercises in
                    updateExercises(with: selectedExercises)
                    showExerciseSelector = false
                }
            }
        }
        .onAppear {
            refreshTemplateData()
        }
        
        
    }
    
    // Rest of your methods...
}
