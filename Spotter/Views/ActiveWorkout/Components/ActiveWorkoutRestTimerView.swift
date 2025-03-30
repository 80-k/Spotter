// ActiveWorkoutRestTimerView.swift
// 활성 운동 화면에서 사용되는 휴식 타이머 컴포넌트
// Created by woo on 3/30/25.

import SwiftUI

struct ActiveWorkoutRestTimerView: View {
    var viewModel: ActiveWorkoutViewModel
    var activeExercise: ExerciseItem
    
    // 애니메이션 효과를 위한 상태 변수
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 12) {
            // 타이머 컴포넌트
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                            .opacity(pulseAnimation ? 0.6 : 1.0)  // 깜빡임 효과
                        
                        Text("\(activeExercise.name) 휴식 중")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Text("다음 세트를 준비하세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 원형 타이머
                ActiveWorkoutTimerCircleView(
                    remainingTime: viewModel.remainingRestTime,
                    totalTime: viewModel.currentActiveSet?.restTime ?? 60
                )
            }
            .padding(.vertical, 16)
            .padding(.horizontal)
        }
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .onAppear {
            // 폴싱 애니메이션 시작
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

// 원형 타이머 컴포넌트
struct ActiveWorkoutTimerCircleView: View {
    let remainingTime: TimeInterval
    let totalTime: TimeInterval
    
    var body: some View {
        ZStack {
            // 배경 원
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                .frame(width: 70, height: 70)
            
            // 타이머 진행 원
            Circle()
                .trim(from: 0, to: CGFloat(remainingTime / totalTime))
                .stroke(
                    Color.blue,
                    style: StrokeStyle(
                        lineWidth: 6,
                        lineCap: .round
                    )
                )
                .frame(width: 70, height: 70)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: remainingTime)
            
            // 타이머 텍스트
            VStack(spacing: 0) {
                Text(formatTime(remainingTime))
                    .font(.headline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                
                Text("초")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // 시간 포맷팅 (초 단위로만 표시)
    private func formatTime(_ seconds: TimeInterval) -> String {
        return "\(Int(seconds))"
    }
}
