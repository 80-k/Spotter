// ExerciseListView.swift
// 운동 목록 컴포넌트 - 템플릿 상세 화면에서 사용
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct ExerciseListView: View {
    let exercises: [ExerciseItem]
    let onAddExercise: () -> Void
    let onRemoveExercise: (ExerciseItem) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더 영역
            HStack {
                Text("운동 목록")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onAddExercise) {
                    Label("운동 추가", systemImage: "plus")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            if !exercises.isEmpty {
                // 운동 항목 목록
                LazyVStack(spacing: 8) {
                    ForEach(exercises) { exercise in
                        ExerciseRowView(exercise: exercise)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .contextMenu {
                                Button(role: .destructive) {
                                    onRemoveExercise(exercise)
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.bottom, 8)
            } else {
                // 운동이 없는 경우
                EmptyExerciseView(onAddExercise: onAddExercise)
            }
        }
    }
}

// 빈 상태 뷰 컴포넌트
struct EmptyExerciseView: View {
    let onAddExercise: () -> Void
    
    var body: some View {
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
            
            Button(action: onAddExercise) {
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
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(Color(.systemBackground))
    }
}
