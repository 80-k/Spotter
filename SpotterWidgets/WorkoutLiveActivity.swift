//
//  WorkoutLiveActivity.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import WidgetKit
import SwiftUI
import ActivityKit

struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // 다이나믹 아일랜드 (컴팩트) 뷰
            LiveActivityCompactView(context: context)
                .activityBackgroundTint(context.state.isRestTimer ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2))
                .activitySystemActionForegroundColor(context.state.isRestTimer ? .orange : .blue)
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
                if context.state.isRestTimer {
                    HStack(spacing: 2) {
                        Image(systemName: "timer")
                            .foregroundColor(.orange)
                        Text("\(context.state.restTimeRemaining)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundColor(.orange)
                    }
                } else {
                    HStack(spacing: 2) {
                        Image(systemName: "figure.run")
                        Text(formatTime(context.state.elapsedTime))
                            .font(.caption2)
                            .monospacedDigit()
                    }
                }
            } compactTrailing: {
                // 미니 컴팩트 뷰 (오른쪽)
                if context.state.isRestTimer {
                    Image(systemName: "figure.cooldown")
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "dumbbell.fill")
                }
            } minimal: {
                // 최소 뷰
                if context.state.isRestTimer {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "dumbbell.fill")
                }
            }
            .widgetURL(URL(string: "spotter://workout"))
            .keylineTint(context.state.isRestTimer ? Color.orange : Color.blue)
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
