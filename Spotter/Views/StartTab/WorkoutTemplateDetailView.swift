//
//  WorkoutTemplateDetailView.swift
// 운동 계획 템플릿 상세 화면 (스택 네비게이션 방식)
//
//  Created by woo on 3/31/25.
//

import SwiftUI
import SwiftData

struct WorkoutTemplateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
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
            VStack(alignment: .leading, spacing: 10) {
                Text(template.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let exercises = template.exercises, !exercises.isEmpty {
                    Text("\(exercises.count)개 운동")
                        .font(.headline)
                        .foregroundColor(.secondary)
                } else {
                    Text("운동 없음")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            // 운동 시작 버튼
            Button(action: {
                let session = viewModel.startWorkout(with: template)
                onStartWorkout(session)
            }) {
                Text("운동 시작")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(template.exercises?.isEmpty ?? true)
            
            Divider()
                .padding(.top, 8)
            
            // 운동 목록
            exerciseList
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
        // 최신 네비게이션 API 사용
        .navigationDestination(isPresented: $navigateToExerciseSelector) {
            WorkoutSelectionView(
                initialSelection: template.exercises ?? []
            ) { selectedExercises in
                // 선택 완료 시 기존 운동 목록을 새로운 선택으로 대체
                updateExercises(with: selectedExercises)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            WorkoutTemplateEditView(viewModel: viewModel, template: template)
        }
    }
    
    // 운동 목록 뷰
    private var exerciseList: some View {
        VStack(spacing: 0) {
            // 헤더 영역
            HStack {
                Text("운동 목록")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    navigateToExerciseSelector = true
                }) {
                    Label("운동 추가", systemImage: "plus")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            if let exercises = template.exercises, !exercises.isEmpty {
                List {
                    ForEach(exercises) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                    .onDelete { indexSet in
                        removeExercises(at: indexSet)
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                // 운동이 없는 경우
                VStack(spacing: 16) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("운동이 없습니다")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("+ 버튼을 눌러 운동을 추가하세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0.8))
                    
                    Button(action: {
                        navigateToExerciseSelector = true
                    }) {
                        Label("운동 추가하기", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
    }
    
    // 선택된 운동 목록으로 업데이트
    private func updateExercises(with exercises: [ExerciseItem]) {
        // 모든 기존 운동 제거 후 새 운동 추가
        template.exercises = []
        
        // 새 운동 추가
        for exercise in exercises {
            template.addExercise(exercise)
        }
        
        // 변경사항 저장
        viewModel.updateTemplate(template)
    }
    
    // 특정 인덱스의 운동 제거
    private func removeExercises(at offsets: IndexSet) {
        guard let exercises = template.exercises else { return }
        
        for index in offsets {
            let exercise = exercises[index]
            template.removeExercise(exercise)
        }
        
        // 변경사항 저장
        viewModel.updateTemplate(template)
    }
}

// 운동 행 컴포넌트
struct ExerciseRow: View {
    let exercise: ExerciseItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                
                Text(exercise.muscleGroup)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}
