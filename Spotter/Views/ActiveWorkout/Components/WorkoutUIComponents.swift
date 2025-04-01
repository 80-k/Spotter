// WorkoutUIComponents.swift
// 운동 UI 관련 공통 컴포넌트 모음
// Created by woo on 3/30/25.

import SwiftUI

// 세션 헤더 - 시간 및 제어 버튼
// WorkoutHeaderView → ActiveWorkoutHeaderView 이름 변경
struct ActiveWorkoutHeaderView: View {
    let elapsedTime: TimeInterval
    let onCancel: () -> Void
    let onComplete: () -> Void
    let isCompleteEnabled: Bool
    var templateName: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 템플릿 이름과 운동 세션 진행 중 표시
            if let name = templateName {
                HStack {
                    Text("\(name) - 운동 세션 진행 중")
                        .font(.headline)
                        .foregroundColor(Color.primary)
                        .padding(.horizontal)
                        .padding(.top, 4)
                    
                    Spacer()
                }
            }
            
            HStack {
                // 경과 시간
                StopwatchView(elapsedTime: elapsedTime)
                    .font(.title2)
                
                Spacer()
                
                // 취소 버튼
                Button(action: onCancel) {
                    Text("취소")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.trailing, 8)
                
                // 완료 버튼
                Button(action: onComplete) {
                    Text("완료")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isCompleteEnabled ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!isCompleteEnabled)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
        }
    }
}

// 참고: 기존 운동 헤더 컴포넌트(ActiveExerciseHeaderView)와 
// ExerciseCompletionStatus 열거형은 ExerciseHeaderView.swift로 통합되었습니다.
// ExerciseHeaderView로 대체하여 사용하세요.

// 섹션 헤더 컴포넌트
// SectionHeader → WorkoutSectionHeaderView 이름 변경
struct WorkoutSectionHeaderView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            Spacer()
        }
        .padding(.top, 8)
    }
}

// 운동 추가 버튼
// AddExerciseButton → WorkoutAddExerciseButton 이름 변경
struct WorkoutAddExerciseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                Text("운동 추가")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}
