// SetListContainer.swift
// 세트 목록 컨테이너 뷰 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI

// 세트 목록 컨테이너 뷰
struct SetListContainer: View {
    @Binding var sets: [WorkoutSet]
    var viewModel: ActiveWorkoutViewModel
    var exercise: ExerciseItem
    var isActive: Bool
    var isEditMode: Bool
    
    var body: some View {
        ZStack {
            // 배경 및 테두리
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            
            // 세트 목록 컨텐츠
            VStack(spacing: 0) {
                if sets.isEmpty {
                    Text("세트가 없습니다")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(height: 60)
                } else {
                    // 세트 목록 - 높이 제한 없이 자동으로 늘어나도록 변경
                    if isEditMode {
                        // 편집 모드일 때 드래그 가능한 세트 목록
                        DraggableSetListView(
                            sets: $sets,
                            viewModel: viewModel,
                            exercise: exercise,
                            isActive: isActive
                        )
                    } else {
                        // 일반 모드일 때 정적 세트 목록
                        StaticSetListView(
                            sets: sets,
                            viewModel: viewModel,
                            exercise: exercise,
                            isActive: isActive
                        )
                    }
                }
            }
            .id(sets.count) // 세트 수를 ID로 사용하여 세트 추가 시 뷰 강제 새로고침
            .padding(.vertical, 4)
        }
        .padding(.horizontal, 8)
        // 높이 제한 제거 - 자동으로 콘텐츠에 맞게 조정
        .frame(minHeight: sets.isEmpty ? 60 : nil)
    }
}
