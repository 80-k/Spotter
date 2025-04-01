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
            // 락 스크린 및 배너 UI
            VStack {
                LiveActivityCompactView(context: context)
            }
            .activityBackgroundTint(context.state.isRestMode ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2))
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // 확장된 다이나믹 아일랜드
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
                // 컴팩트 왼쪽
                Label {
                    Text(context.state.isRestMode ? "휴식" : "운동")
                        .font(.caption2)
                } icon: {
                    Image(systemName: context.state.isRestMode ? "timer" : "dumbbell.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(context.state.isRestMode ? .orange : .blue)
                }
            } compactTrailing: {
                // 컴팩트 오른쪽
                if context.state.isRestMode {
                    Text("\(context.state.remainingRestTime)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .minimumScaleFactor(0.7)
                        .frame(minWidth: 28, alignment: .trailing)
                        .foregroundStyle(.orange)
                        .contentTransition(.numericText())
                        .animation(.smooth, value: context.state.remainingRestTime)
                } else {
                    // 경과 시간
                    Text(formatTime(context.state.elapsedSeconds))
                        .font(.caption2)
                        .monospacedDigit()
                        .foregroundStyle(.blue)
                        .contentTransition(.numericText())
                        .animation(.smooth, value: context.state.elapsedSeconds)
                }
            } minimal: {
                // 최소 표시
                if context.state.isRestMode {
                    ZStack {
                        Image(systemName: "timer")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.orange)
                        
                        // 타이머 원형 진행 상태 표시
                        Circle()
                            .trim(from: 0, to: min(1, CGFloat(context.state.remainingRestTime) / 60.0))
                            .stroke(
                                Color.orange.opacity(0.7),
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 14, height: 14)
                    }
                } else {
                    Image(systemName: "dumbbell.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue)
                }
            }
            .widgetURL(URL(string: "spotter://workout"))
            .keylineTint(context.state.isRestMode ? .orange : .blue)
        }
    }
    
    // 시간 포맷 유틸리티
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
