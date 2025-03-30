// WorkoutTemplateDetailView.swift
// 운동 계획 템플릿 상세 화면 - 코어 컨테이너 컴포넌트
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct WorkoutTemplateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData 모델
    @State private var template: WorkoutTemplate
    @State private var showingEditSheet = false
    @State private var navigateToExerciseSelector = false
    
    var viewModel: WorkoutTemplateListViewModel
    var onStartWorkout: (WorkoutSession) -> Void
    
    init(template: WorkoutTemplate, viewModel: WorkoutTemplateListViewModel, onStartWorkout: @escaping (WorkoutSession) -> Void) {
        self._template = State(initialValue: template)
        self.viewModel = viewModel
        self.onStartWorkout = onStartWorkout
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            TemplateHeaderView(
                name: template.name,
                exerciseCount: template.exercises?.count ?? 0
            )
            
            Divider()
                .padding(.top, 4)
            
            // 운동 목록 - 스크롤 가능한 영역
            ScrollView {
                ExerciseListView(
                    exercises: template.exercises ?? [],
                    onAddExercise: {
                        navigateToExerciseSelector = true
                    },
                    onRemoveExercise: { exercise in
                        removeExercise(exercise)
                    }
                )
                
                // 빈 공간 추가 (버튼을 위한 공간 확보)
                Spacer(minLength: 100)
            }
            
            // 하단 고정 영역
            StartWorkoutButtonView(
                isDisabled: template.exercises?.isEmpty ?? true,
                onStartWorkout: {
                    let session = viewModel.startWorkout(with: template)
                    onStartWorkout(session)
                }
            )
        }
        .navigationTitle("템플릿 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Label("편집", systemImage: "pencil")
                }
            }
        }
        // 네비게이션 링크 대신 navigationDestination 사용
        .navigationDestination(isPresented: $navigateToExerciseSelector) {
            WorkoutSelectionView(
                initialSelection: template.exercises ?? []
            ) { selectedExercises in
                updateExercises(with: selectedExercises)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            WorkoutTemplateEditView(viewModel: viewModel, template: template)
        }
        // 뷰가 나타날 때마다 템플릿 데이터 다시 로드
        .onAppear {
            refreshTemplateData()
        }
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
        template.exercises = []
        
        for exercise in exercises {
            template.addExercise(exercise)
        }
        
        viewModel.updateTemplate(template)
        refreshTemplateData()
    }
    
    // 특정 운동 제거
    private func removeExercise(_ exercise: ExerciseItem) {
        template.removeExercise(exercise)
        viewModel.updateTemplate(template)
        refreshTemplateData()
    }
}
