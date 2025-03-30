//
//  RestTimerSectionView.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

// 휴식 타이머 섹션 뷰 - 향상된 버전
struct RestTimerSectionView: View {
    var exercise: ExerciseItem
    var remainingTime: TimeInterval
    var totalTime: TimeInterval
    
    var body: some View {
        VStack(spacing: 12) {
            // 타이머 컴포넌트
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                        Text("\(exercise.name) 휴식 중")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Text("다음 세트를 준비하세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    // 타이머 배경 원
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 70, height: 70)
                    
                    // 타이머 진행 원
                    Circle()
                        .trim(from: 0, to: CGFloat(remainingTime / totalTime))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                    
                    // 타이머 텍스트
                    Text(formatTime(remainingTime))
                        .font(.headline)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal)
        }
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // 시간 포맷팅
    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
