// SetRowSwipeActions.swift
// SwiftUI 기본 스와이프 액션
// Created by woo on 4/30/23.

import SwiftUI
import os

// 로깅을 위한 Logger 설정
private let logger = Logger(subsystem: "com.spotter.app", category: "SetRowSwipeActions")

// 기본 SwiftUI 스와이프 액션 구조체
struct SetRowSwipeActions: ViewModifier {
    var set: WorkoutSet
    var onDelete: () -> Void
    var onToggleCompletion: () -> Void
    var isHighlighted: Bool
    
    func body(content: Content) -> some View {
        content
            // 왼쪽으로 스와이프하면 삭제 (오른쪽 가장자리에 버튼 표시)
            .swipeActions(edge: .trailing, allowsFullSwipe: isHighlighted) {
                Button(role: .destructive) {
                    withAnimation {
                        logger.debug("SwiftUI 기본 스와이프: 삭제 액션")
                        onDelete()
                    }
                } label: {
                    Label("삭제", systemImage: "trash")
                }
                .tint(.red)
            }
            // 오른쪽으로 스와이프하면 완료/취소 (왼쪽 가장자리에 버튼 표시)
            .swipeActions(edge: .leading, allowsFullSwipe: isHighlighted) {
                Button {
                    withAnimation {
                        logger.debug("SwiftUI 기본 스와이프: 완료/취소 액션")
                        onToggleCompletion()
                    }
                } label: {
                    if set.isCompleted {
                        Label("취소", systemImage: "arrow.uturn.backward")
                    } else {
                        Label("완료", systemImage: "checkmark")
                    }
                }
                .tint(set.isCompleted ? .orange : .green)
            }
    }
} 