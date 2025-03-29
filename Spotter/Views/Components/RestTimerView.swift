//
//  RestTimerView.swift
//  휴식 타이머 및 세트 정보를 표시하는 확장 뷰
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct RestTimerView: View {
    var exercise: ExerciseItem
    var remainingTime: TimeInterval
    var totalTime: TimeInterval
    
    var body: some View {
        VStack(spacing: 12) {
            // 타이머 컴포넌트
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    // 원형 타이머
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(remainingTime / totalTime))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text(formatTime(remainingTime))
                                .font(.title2)
                                .fontWeight(.bold)
                                .monospacedDigit()
                            
                            Text("휴식")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("\(exercise.name) 휴식 중")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 16)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // 시간 포맷팅
    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
