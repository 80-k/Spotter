// SwipeActionExtensions.swift
// 스와이프 액션 View 확장 메서드
// Created by woo on 4/30/23.

import SwiftUI
import SwiftData

// SwiftUI View 확장 - 스와이프 액션 적용
extension View {
    // 커스텀 스와이프 액션 적용
    func withCustomSwipeActions(
        set: WorkoutSet, 
        onDelete: @escaping () -> Void, 
        onToggleCompletion: @escaping () -> Void,
        isHighlighted: Bool = false
    ) -> some View {
        self.modifier(SwipeActionsView(
            set: set, 
            onDelete: onDelete, 
            onToggleCompletion: onToggleCompletion,
            isHighlighted: isHighlighted
        ))
    }
    
    // 기본 SwiftUI 스와이프 액션 적용
    func withSetRowSwipeActions(
        set: WorkoutSet, 
        onDelete: @escaping () -> Void, 
        onToggleCompletion: @escaping () -> Void,
        isHighlighted: Bool = false
    ) -> some View {
        self.modifier(SetRowSwipeActions(
            set: set, 
            onDelete: onDelete, 
            onToggleCompletion: onToggleCompletion,
            isHighlighted: isHighlighted
        ))
    }
} 