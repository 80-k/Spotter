// InputFieldUtilities.swift
// 입력 필드 유틸리티 함수
// Created by woo on 3/29/25.

import SwiftUI

// 무게 값 포맷팅 헬퍼 함수
func formatWeightValue(_ weight: Double) -> String {
    if weight <= 0 {
        return ""
    }
    
    // 소수점 이하가 0인지 확인 (정수인지)
    let isInteger = weight.truncatingRemainder(dividingBy: 1) == 0
    
    if isInteger {
        return "\(Int(weight))"
    } else {
        return String(format: "%.1f", weight)
    }
}

// 필드 배경색 계산 함수
func getFieldBackgroundColor(showWarning: Bool, isFocused: Bool, isCompleted: Bool) -> Color {
    if showWarning {
        return SpotColor.danger.opacity(0.08)
    } else if isFocused {
        return SpotColor.inputFocused.opacity(0.08)
    } else if isCompleted {
        return SpotColor.completedSet.opacity(0.08)
    } else {
        return Color(.tertiarySystemGroupedBackground)
    }
}

// 필드 테두리색 계산 함수
func getFieldBorderColor(showWarning: Bool, isFocused: Bool, isCompleted: Bool) -> Color {
    if showWarning {
        return SpotColor.danger
    } else if isFocused {
        return SpotColor.primary
    } else if isCompleted {
        return SpotColor.success
    } else {
        return Color.clear
    }
} 