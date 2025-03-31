// ExerciseDetailView.swift
// 운동 상세 정보 화면
// Created by woo on 4/1/25.

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let exercise: ExerciseItem
    
    var body: some View {
        VStack(spacing: 16) {
            // 운동 정보 헤더
            VStack(spacing: 8) {
                Text(exercise.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(exercise.muscleGroup)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            // 운동 상세 정보
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(title: "운동 ID", value: "\(exercise.id)")
                
                InfoRow(title: "운동 종류", value: exercise.muscleGroup)
                
                if let note = exercise.note, !note.isEmpty {
                    InfoRow(title: "메모", value: note)
                }
                
                InfoRow(title: "생성일", value: formatDate(exercise.createdAt))
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("운동 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// 정보 행 컴포넌트
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
} 