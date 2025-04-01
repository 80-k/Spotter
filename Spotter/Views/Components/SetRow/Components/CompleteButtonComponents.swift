// CompleteButtonComponents.swift
// 운동 세트 행 완료 버튼 컴포넌트
// Created by woo on 3/29/25.

import SwiftUI

// 세트 완료 버튼 컴포넌트
struct CompleteButton: View {
    var set: WorkoutSet
    var disableCompleteButton: Bool
    var onCompleteToggle: () -> Void
    var onValidation: () -> Bool
    
    var body: some View {
        Button(action: handleButtonTap) {
            if set.isCompleted {
                completedButton
            } else {
                incompleteButton
            }
        }
        .disabled(disableCompleteButton && !set.isCompleted) // 완료 버튼만 비활성화
    }
    
    // 완료된 상태 버튼
    private var completedButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(SpotColor.success)
            
            Text("재개")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(SpotColor.success)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(SpotColor.success.opacity(0.1))
        )
    }
    
    // 미완료 상태 버튼
    private var incompleteButton: some View {
        Text("휴식")
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(disableCompleteButton ? Color(.systemGray3) : SpotColor.primary)
            )
    }
    
    // 버튼 탭 처리
    private func handleButtonTap() {
        if !set.isCompleted {
            // 유효성 검증 후 완료 처리
            if onValidation() {
                onCompleteToggle()
                
                // 진동 피드백 (완료)
                #if os(iOS)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                #endif
            } else {
                // 진동 피드백 (경고)
                #if os(iOS)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                #endif
            }
        } else {
            // 이미 완료된 세트는 바로 재개
            onCompleteToggle()
        }
    }
}

// 세트 번호 원 컴포넌트
struct SetNumberCircle: View {
    var setNumber: Int
    var isCompleted: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? SpotColor.success.opacity(0.12) : SpotColor.primary.opacity(0.12))
                .frame(width: 32, height: 32)
            
            Text("\(setNumber)")
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(isCompleted ? SpotColor.success : SpotColor.primary)
        }
    }
} 