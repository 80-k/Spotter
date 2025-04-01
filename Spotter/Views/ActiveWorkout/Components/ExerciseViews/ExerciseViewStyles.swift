// ExerciseViewStyles.swift
// 운동 뷰 스타일 관련 확장 및 수정자
// Created by woo on 4/01/25.

import SwiftUI

/// 운동 스타일 도우미
enum ExerciseStyleHelper {
    /// 운동 컨테이너 배경 색상을 반환합니다
    static func backgroundColor(status: ExerciseCompletionStatus, isActive: Bool) -> Color {
        // status 자체의 backgroundColor 속성을 활용
        status.backgroundColor
    }
    
    /// 운동 컨테이너 테두리 색상을 반환합니다
    static func borderColor(status: ExerciseCompletionStatus, isActive: Bool) -> Color {
        // status 자체의 borderColor 속성을 활용
        status.borderColor
    }
}

/// 운동 뷰 수정자
extension View {
    /// 운동 컨테이너 스타일을 적용합니다
    func exerciseContainerStyle(
        status: ExerciseCompletionStatus, 
        isActive: Bool,
        isMinimized: Bool
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ExerciseStyleHelper.backgroundColor(status: status, isActive: isActive))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        ExerciseStyleHelper.borderColor(status: status, isActive: isActive),
                        lineWidth: 1
                    )
            )
            .cornerRadius(12)
            .contentShape(Rectangle())
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isMinimized)
            .frame(height: isMinimized ? 65 : nil)
    }
}

/**
 * 참고: exerciseContainerStyle 확장은 ActiveWorkoutExerciseView.swift 파일에도
 * 정의되어 있으므로 여기서는 삭제합니다.
 */
/* 운동 뷰 수정자
extension View {
    /// 운동 컨테이너 스타일을 적용합니다
    func exerciseContainerStyle(
        status: ExerciseCompletionStatus, 
        isActive: Bool,
        isMinimized: Bool
    ) -> some View {
        self
            .background(ExerciseViewStyles.containerBackground(status: status, isActive: isActive))
            .overlay(ExerciseViewStyles.containerBorder(status: status, isActive: isActive))
            .cornerRadius(12)
            .contentShape(Rectangle())
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isMinimized)
            .frame(height: isMinimized ? 65 : nil)
    }
} */ 