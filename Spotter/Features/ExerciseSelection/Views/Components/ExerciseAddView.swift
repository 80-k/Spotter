// ExerciseAddView.swift
// 새 운동 추가 화면
// Created by woo on 4/1/25.

import SwiftUI
import SwiftData

struct ExerciseAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String = ""
    @State private var muscleGroup: String = MuscleGroup.chest.rawValue
    @State private var exerciseDescription: String = ""
    
    // 콜백 함수: 운동이 추가되면 호출됨
    var onComplete: (ExerciseItem?) -> Void
    
    init(onComplete: @escaping (ExerciseItem?) -> Void) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("운동 정보")) {
                    TextField("운동 이름", text: $name)
                    
                    Picker("운동 부위", selection: $muscleGroup) {
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            Text(group.rawValue).tag(group.rawValue)
                        }
                    }
                }
                
                Section(header: Text("상세 설명")) {
                    TextEditor(text: $exerciseDescription)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("새 운동 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        onComplete(nil)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        let newExercise = addExercise()
                        onComplete(newExercise)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addExercise() -> ExerciseItem? {
        guard !name.isEmpty else { return nil }
        
        // 새 운동 생성
        let newExercise = ExerciseItem(
            name: name,
            muscleGroup: muscleGroup,
            exerciseDescription: exerciseDescription
        )
        
        // 모델 컨텍스트에 추가
        modelContext.insert(newExercise)
        
        do {
            try modelContext.save()
            return newExercise
        } catch {
            print("운동 추가 중 오류 발생: \(error)")
            return nil
        }
    }
} 