// EmptyExerciseView.swift
// 빈 운동 목록 상태 표시
// Created by woo on 4/1/25.

import SwiftUI

struct EmptyExerciseView: View {
    let onAddExercise: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.4))
            
            Text("등록된 운동이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("새 운동을 등록해보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onAddExercise) {
                Label("새 운동 추가하기", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 250)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding()
    }
} 