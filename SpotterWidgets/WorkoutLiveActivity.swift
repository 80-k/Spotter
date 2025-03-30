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
