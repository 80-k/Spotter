//
//  WorkoutTemplateDetailView.swift
// 운동 계획 템플릿 상세 화면 (운동 시작 준비 화면)
//
//  Created by woo on 3/29/25.
//

import SwiftUI
import SwiftData

struct WorkoutTemplateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var template: WorkoutTemplate
    @State private var showingEditSheet = false
    @State private var showingExerciseSelector = false
    
    var viewModel: WorkoutTemplateListViewModel
    var onStartWorkout: (WorkoutSession) -> Void
    
    init(template: WorkoutTemplate, viewModel: WorkoutTemplateListViewModel, onStartWorkout: @escaping (WorkoutSession) -> Void) {
        self._template = State(initialValue: template)
        self.viewModel = viewModel
        self.onStartWorkout = onStartWorkout
    }
    
    var body: some View {
        NavigationStack {
            VStack {
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
                    dismiss()
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
                
                // 운동 목록
                List {
                    Section(header:
                        HStack {
                            Text("운동 목록")
                            Spacer()
                            Button(action: {
                                showingExerciseSelector = true
                            }) {
                                Label("운동 추가", systemImage: "plus")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    ) {
                        if let exercises = template.exercises, !exercises.isEmpty {
                            ForEach(exercises) { exercise in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(exercise.name)
                                            .font(.headline)
                                        Text(exercise.muscleGroup)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.removeExerciseFromTemplate(exercise, template: template)
                                    }) {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        } else {
                            Text("운동을 추가해주세요")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("편집", systemImage: "pencil")
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
            .sheet(isPresented: $showingExerciseSelector) {
                ExerciseSelectorView(template: template, viewModel: viewModel)
            }
        }
    }
}

// 운동 선택 화면
struct ExerciseSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText = ""
    @State private var exercises: [ExerciseItem] = []
    @State private var showingAddExercise = false
    
    var template: WorkoutTemplate
    var viewModel: WorkoutTemplateListViewModel
    
    init(template: WorkoutTemplate, viewModel: WorkoutTemplateListViewModel) {
        self.template = template
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredExercises) { exercise in
                        Button(action: {
                            viewModel.addExerciseToTemplate(exercise, template: template)
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .font(.headline)
                                    Text(exercise.muscleGroup)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // 이미 템플릿에 포함되어 있는지 확인
                                if isExerciseInTemplate(exercise) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                
                // 새 운동 추가 버튼
                Button(action: {
                    showingAddExercise = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("새 운동 등록하기")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("운동 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "운동 이름 검색")
            .onAppear {
                fetchExercises()
            }
            .sheet(isPresented: $showingAddExercise) {
                ExerciseAddView { newExercise in
                    // 새 운동이 생성되면 목록 갱신
                    fetchExercises()
                    
                    // 새 운동을 바로 템플릿에 추가할지 결정
                    if let newExercise = newExercise {
                        viewModel.addExerciseToTemplate(newExercise, template: template)
                    }
                }
            }
        }
    }
    
    // 현재 템플릿에 포함된 운동인지 확인
    private func isExerciseInTemplate(_ exercise: ExerciseItem) -> Bool {
        return template.exercises?.contains(where: { $0.id == exercise.id }) ?? false
    }
    
    // 모든 운동 가져오기
    private func fetchExercises() {
        do {
            let descriptor = FetchDescriptor<ExerciseItem>(sortBy: [SortDescriptor(\.name)])
            exercises = try modelContext.fetch(descriptor)
        } catch {
            print("운동 목록을 가져오는 중 오류 발생: \(error)")
        }
    }
    
    // 검색어로 필터링된 운동 목록
    var filteredExercises: [ExerciseItem] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
