// ExerciseSelectionRow.swift
// 운동 선택 행 컴포넌트
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct ExerciseSelectionRow: View {
    let exercise: ExerciseItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                    
                    HStack {
                        Text(exercise.muscleGroup)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // 운동 설명이 있는 경우 아이콘 표시
                        if !exercise.exerciseDescription.isEmpty {
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // 선택 상태 표시
                SelectionCheckmark(isSelected: isSelected)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}

// 선택 상태 체크마크 컴포넌트
struct SelectionCheckmark: View {
    let isSelected: Bool
    
    var body: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .foregroundColor(isSelected ? .blue : .gray)
            .imageScale(.large)
            .animation(.snappy, value: isSelected)
    }
}

// MARK: - 미리보기

#Preview {
    VStack {
        // 선택된 운동
        ExerciseSelectionRow(
            exercise: ExerciseItem(
                name: "벤치 프레스",
                muscleGroup: "가슴",
                exerciseDescription: "가슴 운동의 기본"
            ),
            isSelected: true,
            onToggle: {}
        )
        
        // 선택되지 않은 운동
        ExerciseSelectionRow(
            exercise: ExerciseItem(
                name: "스쿼트",
                muscleGroup: "하체",
                exerciseDescription: ""
            ),
            isSelected: false,
            onToggle: {}
        )
    }
    .padding()
}
