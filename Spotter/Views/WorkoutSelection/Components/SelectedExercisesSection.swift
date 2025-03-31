// SelectedExercisesSection.swift
// 선택된 운동 목록 섹션 컴포넌트
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct SelectedExercisesSection: View {
    @Binding var selectedExercises: [ExerciseItem]
    let onRemoveExercise: (ExerciseItem) -> Void
    
    var body: some View {
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
                                    onRemoveExercise(exercise)
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

// MARK: - 미리보기

#Preview {
    struct PreviewWrapper: View {
        @State private var exercises = [
            ExerciseItem(name: "벤치 프레스", muscleGroup: "가슴"),
            ExerciseItem(name: "스쿼트", muscleGroup: "하체"),
            ExerciseItem(name: "데드리프트", muscleGroup: "등")
        ]
        
        var body: some View {
            VStack {
                // 운동이 있는 경우
                SelectedExercisesSection(
                    selectedExercises: $exercises,
                    onRemoveExercise: { _ in }
                )
                
                Divider()
                
                // 운동이 없는 경우
                SelectedExercisesSection(
                    selectedExercises: .constant([]),
                    onRemoveExercise: { _ in }
                )
            }
        }
    }
    
    return PreviewWrapper()
}
