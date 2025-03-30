// ExerciseRowView.swift
// 운동 항목 행 컴포넌트 - 운동 목록에서 사용
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct ExerciseRowView: View {
    let exercise: ExerciseItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                
                Text(exercise.muscleGroup)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // 운동 세부 설명이 있는 경우 표시
                if !exercise.exerciseDescription.isEmpty {
                    Text(exercise.exerciseDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(8)
    }
}

// 미리보기 제공
#Preview {
    ExerciseRowView(
        exercise: ExerciseItem(
            name: "벤치 프레스",
            muscleGroup: "가슴",
            exerciseDescription: "가슴 운동의 기본"
        )
    )
    .previewLayout(.sizeThatFits)
    .padding()
}
