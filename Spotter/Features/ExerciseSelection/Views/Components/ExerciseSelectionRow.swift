// ExerciseSelectionRow.swift
// 운동 선택 화면의 각 운동 항목 행
// Created by woo on 4/1/25.

import SwiftUI
import SwiftData

struct ExerciseSelectionRow: View {
    let exercise: ExerciseItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                // 선택 체크 마크
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(.body, weight: .medium))
                    
                    Text(exercise.muscleGroup)
                        .font(.system(.caption))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
} 