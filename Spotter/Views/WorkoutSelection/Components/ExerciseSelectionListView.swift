// ExerciseSelectionListView.swift
// 운동 선택 목록 컴포넌트
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct ExerciseSelectionListView: View {
    let exercises: [ExerciseItem]
    let selectedExercises: [ExerciseItem]
    let onToggleSelection: (ExerciseItem) -> Void
    let onAddNewExercise: () -> Void
    
    var body: some View {
        List {
            // 운동 목록
            ForEach(exercises) { exercise in
                ExerciseSelectionRow(
                    exercise: exercise,
                    isSelected: isExerciseSelected(exercise),
                    onToggle: {
                        onToggleSelection(exercise)
                    }
                )
            }
            
            // 새 운동 추가 버튼
            NewExerciseButton(onAddNewExercise: onAddNewExercise)
                .padding(.vertical, 4)
            
            // 빈 운동 목록인 경우 안내 문구
            if exercises.isEmpty {
                EmptyExerciseSection()
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // 운동이 현재 선택되었는지 확인
    private func isExerciseSelected(_ exercise: ExerciseItem) -> Bool {
        return selectedExercises.contains { $0.id == exercise.id }
    }
}

// 새 운동 추가 버튼
struct NewExerciseButton: View {
    let onAddNewExercise: () -> Void
    
    var body: some View {
        Button(action: onAddNewExercise) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .imageScale(.large)
                
                Text("새 운동 등록하기")
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 8)
    }
}

// 빈 운동 목록 섹션
struct EmptyExerciseSection: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.4))
                .padding(.top, 20)
            
            Text("등록된 운동이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("새 운동을 등록하거나 검색어를 확인해보세요")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - 미리보기

#Preview {
    ExerciseSelectionListView(
        exercises: [
            ExerciseItem(name: "벤치 프레스", muscleGroup: "가슴"),
            ExerciseItem(name: "스쿼트", muscleGroup: "하체"),
            ExerciseItem(name: "데드리프트", muscleGroup: "등")
        ],
        selectedExercises: [
            ExerciseItem(name: "벤치 프레스", muscleGroup: "가슴")
        ],
        onToggleSelection: { _ in },
        onAddNewExercise: {}
    )
}
