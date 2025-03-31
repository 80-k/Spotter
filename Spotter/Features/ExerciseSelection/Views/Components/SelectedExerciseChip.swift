// SelectedExerciseChip.swift
// 선택된 운동을 표시하는 칩 컴포넌트
// Created by woo on 4/1/25.

import SwiftUI

struct SelectedExerciseChip: View {
    let name: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.system(.subheadline, weight: .medium))
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
            }
            .foregroundColor(.primary.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.accentColor.opacity(0.15))
        )
    }
} 