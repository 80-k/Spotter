// SwipeActionsView.swift
// 커스텀 스와이프 액션 뷰 모디파이어
// Created by woo on 4/30/23.

import SwiftUI
import os

// 로깅을 위한 Logger 설정
private let logger = Logger(subsystem: "com.spotter.app", category: "SwipeActionsView")

// 스와이프 액션 뷰
struct SwipeActionsView: ViewModifier {
    var set: WorkoutSet
    var onDelete: () -> Void
    var onToggleCompletion: () -> Void
    var isHighlighted: Bool
    
    @State private var dragAmount = CGSize.zero
    @State private var dragDirection: SwipeDirection? = nil
    
    func body(content: Content) -> some View {
        ZStack {
            // 실제 스와이프 액션 버튼 레이어
            HStack {
                // 오른쪽으로 스와이프 (왼쪽 버튼)
                if dragDirection == .right {
                    CompletionButton(set: set) {
                        onToggleCompletion()
                        resetDrag()
                    }
                }
                
                Spacer()
                
                // 왼쪽으로 스와이프 (오른쪽 버튼)
                if dragDirection == .left {
                    DeleteButton {
                        onDelete()
                        resetDrag()
                    }
                }
            }
            .padding(.horizontal, 8)
            
            // 실제 콘텐츠
            content
                .offset(dragAmount)
                .gesture(createDragGesture())
                .onChange(of: isHighlighted) { _, newValue in
                    // 강조 상태가 변경되면 드래그 상태 초기화
                    if !newValue {
                        logger.debug("강조 상태 변경됨: 드래그 초기화")
                        resetDrag()
                    }
                }
        }
    }
    
    // 드래그 제스처 생성
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged(handleDragChange)
            .onEnded(handleDragEnd)
    }
    
    // 드래그 변경 처리
    private func handleDragChange(_ value: DragGesture.Value) {
        // 강조 모드에서만 스와이프 인식
        if !isHighlighted {
            logger.debug("스와이프 무시: 강조 모드가 아님")
            return
        }
        
        // 스와이프 방향 결정
        if abs(value.translation.width) > abs(value.translation.height) {
            // 가로 방향 스와이프
            if value.translation.width > 0 {
                // 오른쪽으로 스와이프
                dragDirection = .right
                dragAmount.width = min(value.translation.width, 120)
            } else {
                // 왼쪽으로 스와이프
                dragDirection = .left
                dragAmount.width = max(value.translation.width, -120)
            }
        }
    }
    
    // 드래그 종료 처리
    private func handleDragEnd(_ value: DragGesture.Value) {
        // 강조 모드에서만 스와이프 인식
        if !isHighlighted {
            return
        }
        
        logger.debug("스와이프 종료: 방향=\(String(describing: dragDirection)), 이동 거리=\(abs(dragAmount.width))")
        
        // 임계값 체크
        withAnimation {
            if abs(dragAmount.width) > 60 {
                // 스와이프 액션 실행
                if dragDirection == .left {
                    logger.debug("왼쪽 스와이프 액션: 삭제")
                    // 진동 피드백 제공
                    provideFeedback(isDelete: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDelete()
                    }
                } else if dragDirection == .right {
                    logger.debug("오른쪽 스와이프 액션: 완료/취소")
                    // 진동 피드백 제공
                    provideFeedback()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onToggleCompletion()
                    }
                }
                resetDrag()
            } else {
                // 원래 위치로 복귀
                resetDrag()
            }
        }
    }
    
    // 드래그 상태 초기화
    private func resetDrag() {
        withAnimation(.spring()) {
            dragAmount = .zero
            dragDirection = nil
        }
    }
} 
