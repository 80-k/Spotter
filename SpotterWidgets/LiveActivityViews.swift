// LiveActivityViews.swift
// LiveActivity UI 컴포넌트
// Created by woo on 3/30/25.

import SwiftUI
import WidgetKit
import ActivityKit

// 라이브 액티비티 컴팩트 뷰
struct LiveActivityCompactView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(context.attributes.workoutName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if context.state.isRestTimer {
                        HStack {
                            Image(systemName: "timer")
                            Text("\(context.state.restExerciseName) 휴식")
                                .font(.caption)
                                .lineLimit(1)
                        }
                    } else {
                        Text("운동 진행 중")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                if context.state.isRestTimer {
                    // 휴식 타이머 표시
                    VStack {
                        Text("\(context.state.restTimeRemaining)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .frame(minWidth: 60, alignment: .trailing) // 넉넉한 공간 확보
                        
                        Text("초")
                            .font(.caption)
                    }
                } else {
                    // 운동 시간 표시
                    VStack {
                        Text(formatTime(context.state.elapsedTime))
                            .font(.title)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                }
            }
        }
        .padding()
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// 다이나믹 아일랜드 영역 뷰들
struct WorkoutLeadingView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(context.attributes.workoutName)
                .font(.headline)
                .lineLimit(1)
            
            if context.state.isRestTimer {
                Text("휴식 중")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("운동 중")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct WorkoutTrailingView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        if context.state.isRestTimer {
            VStack(alignment: .trailing) {
                Text("\(context.state.restTimeRemaining)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .frame(minWidth: 48, alignment: .trailing) // 3자리 숫자 공간 확보
                
                Text("초")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else {
            VStack(alignment: .trailing) {
                Text(formatTime(context.state.elapsedTime))
                    .font(.headline)
                    .monospacedDigit()
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct WorkoutBottomView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        if context.state.isRestTimer {
            HStack {
                Label("\(context.state.restExerciseName) 휴식", systemImage: "timer")
                    .font(.caption)
                    .lineLimit(1)
                
                Spacer()
                
                Text("다음 세트 준비")
                    .font(.caption)
            }
        } else {
            HStack {
                Label("운동 시간", systemImage: "stopwatch")
                    .font(.caption)
                
                Spacer()
                
                Text("시작: \(formattedStartTime)")
                    .font(.caption)
            }
        }
    }
    
    private var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: context.state.startTime)
    }
}
