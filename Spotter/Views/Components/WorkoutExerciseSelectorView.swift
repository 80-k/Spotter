//
//  WorkoutExerciseSelectorView.swift
//  Spotter
//
//  Created by woo on 3/29/25.

import SwiftUI
import SwiftData

struct WorkoutExerciseSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText = ""
    @State private var exercises: [ExerciseItem] = []
    @State private var showingAddExercise = false
    
    // 콜백 함수만 사용
    let onExerciseSelected: (ExerciseItem) -> Void
    let isExerciseSelected: (ExerciseItem) -> Bool
    
    init(onExerciseSelected: @escaping (ExerciseItem) -> Void,
         isExerciseSelected: @escaping (ExerciseItem) -> Bool) {
        self.onExerciseSelected = onExerciseSelected
        self.isExerciseSelected = isExerciseSelected
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredExercises) { exercise in
                        Button(action: {
                            onExerciseSelected(exercise)
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
                                
                                // 이미 선택되었는지 확인
                                if isExerciseSelected(exercise) {
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
                    
                    // 새 운동을 바로 선택
                    if let newExercise = newExercise {
                        onExerciseSelected(newExercise)
                        dismiss()
                    }
                }
            }
        }
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
