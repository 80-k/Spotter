// SwipeActionButtons.swift
// 스와이프 액션 버튼 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI
import os

// 로깅을 위한 Logger 설정
private let logger = Logger(subsystem: "com.spotter.app", category: "SwipeActionButtons")

// 완료/취소 버튼 (오른쪽으로 스와이프 시 표시됨)
struct CompletionButton: View {
    var set: WorkoutSet
    var onTap: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                logger.debug("완료/취소 버튼 탭됨")
                onTap()
            }
        } label: {
            HStack {
                if set.isCompleted {
                    Image(systemName: "arrow.uturn.backward")
                    Text("취소")
                } else {
                    Image(systemName: "checkmark")
                    Text("완료")
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .foregroundColor(.white)
            .background(set.isCompleted ? Color.orange : Color.green)
            .cornerRadius(10)
        }
        .transition(.move(edge: .leading))
    }
}

// 삭제 버튼 (왼쪽으로 스와이프 시 표시됨)
struct DeleteButton: View {
    var onTap: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                logger.debug("삭제 버튼 탭됨")
                onTap()
            }
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("삭제")
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(10)
        }
        .transition(.move(edge: .trailing))
    }
}

// 진동 피드백 헬퍼 함수
func provideFeedback(isDelete: Bool = false) {
    let generator = UIImpactFeedbackGenerator(style: isDelete ? .medium : .light)
    generator.impactOccurred()
} 