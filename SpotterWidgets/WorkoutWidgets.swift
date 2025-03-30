//
//  WorkoutWidgets.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import WidgetKit
import SwiftUI
import ActivityKit

@main
struct WorkoutWidgets: WidgetBundle {
    var body: some Widget {
        WorkoutLiveActivity()
    }
}

struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // 다이나믹 아일랜드 (컴팩트) 뷰
            LiveActivityCompactView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // 확장되지 않은 기본 뷰
                DynamicIslandExpandedRegion(.leading) {
                    WorkoutLeadingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    WorkoutTrailingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    WorkoutBottomView(context: context)
                }
            } compactLeading: {
                // 미니 컴팩트 뷰 (왼쪽)
                HStack {
                    Image(systemName: "figure.run")
                    Text(formatTime(context.state.elapsedTime))
                        .font(.caption2)
                        .monospacedDigit()
                }
            } compactTrailing: {
                // 미니 컴팩트 뷰 (오른쪽)
                if context.state.isRestTimer {
                    HStack {
                        Image(systemName: "timer")
                        Text("\(context.state.restTimeRemaining)")
                            .font(.caption2)
                            .monospacedDigit()
                    }
                } else {
                    Image(systemName: "dumbbell.fill")
                }
            } minimal: {
                // 최소 뷰
                if context.state.isRestTimer {
                    Image(systemName: "timer")
                } else {
                    Image(systemName: "dumbbell.fill")
                }
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

// 라이브 액티비티 컴팩트 뷰
struct LiveActivityCompactView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(context.attributes.workoutName)
                        .font(.headline)
                    
                    if context.state.isRestTimer {
                        HStack {
                            Image(systemName: "timer")
                            Text("\(context.state.restExerciseName) 휴식")
                                .font(.caption)
                        }
                    } else {
                        Text("운동 진행 중")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                if context.state.isRestTimer {
                    VStack {
                        Text("\(context.state.restTimeRemaining)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .monospacedDigit()
                        
                        Text("초")
                            .font(.caption)
                    }
                } else {
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
                    .font(.headline)
                    .monospacedDigit()
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
