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
                    
                    if context.state.isRestMode {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.orange)
                            Text("\(context.state.restExerciseName) 휴식")
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(.orange.opacity(0.8))
                        }
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                    } else {
                        Text("운동 진행 중")
                            .font(.caption)
                            .foregroundStyle(.blue.opacity(0.8))
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
                
                Spacer()
                
                if context.state.isRestMode {
                    // 휴식 타이머 표시
                    VStack {
                        Text("\(context.state.remainingRestTime)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .minimumScaleFactor(0.8)
                            .frame(minWidth: 64, alignment: .trailing) // 넉넉한 공간 확보
                            .foregroundStyle(.orange)
                            .contentTransition(.numericText())
                            .animation(.smooth, value: context.state.remainingRestTime)
                        
                        Text("초")
                            .font(.caption)
                            .foregroundStyle(.orange.opacity(0.8))
                    }
                    .padding(.trailing, 4) // 오른쪽 여백 추가
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale).animation(.easeInOut(duration: 0.3)),
                        removal: .opacity.combined(with: .scale).animation(.easeInOut(duration: 0.3))
                    ))
                } else {
                    // 운동 시간 표시
                    VStack {
                        Text(formatTime(context.state.elapsedSeconds))
                            .font(.title)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundStyle(.blue)
                            .contentTransition(.numericText())
                            .animation(.smooth, value: context.state.elapsedSeconds)
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale).animation(.easeInOut(duration: 0.3)),
                        removal: .opacity.combined(with: .scale).animation(.easeInOut(duration: 0.3))
                    ))
                }
            }
        }
        .padding()
        .animation(.smooth, value: context.state.isRestMode)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
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
            
            if context.state.isRestMode {
                Text("휴식 중")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            } else {
                Text("운동 중")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .animation(.smooth, value: context.state.isRestMode)
    }
}

struct WorkoutTrailingView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        Group {
            if context.state.isRestMode {
                VStack(alignment: .trailing) {
                    Text("\(context.state.remainingRestTime)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.8)
                        .frame(minWidth: 48, alignment: .trailing) // 3자리 숫자 공간 확보
                        .foregroundStyle(.orange)
                        .contentTransition(.numericText())
                    
                    Text("초")
                        .font(.caption)
                        .foregroundColor(.orange.opacity(0.7))
                }
                .padding(.trailing, 4) // 오른쪽 여백 추가
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity).animation(.easeInOut(duration: 0.3)),
                    removal: .scale.combined(with: .opacity).animation(.easeInOut(duration: 0.3))
                ))
            } else {
                VStack(alignment: .trailing) {
                    Text(formatTime(context.state.elapsedSeconds))
                        .font(.headline)
                        .monospacedDigit()
                        .foregroundStyle(.blue)
                        .contentTransition(.numericText())
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity).animation(.easeInOut(duration: 0.3)),
                    removal: .scale.combined(with: .opacity).animation(.easeInOut(duration: 0.3))
                ))
            }
        }
        .animation(.smooth, value: context.state.isRestMode)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct WorkoutBottomView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        Group {
            if context.state.isRestMode {
                HStack {
                    Label {
                        Text("\(context.state.restExerciseName) 휴식")
                            .font(.caption)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "timer")
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Text("다음 세트 준비")
                        .font(.caption)
                        .foregroundColor(.orange.opacity(0.7))
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity).animation(.easeInOut(duration: 0.3)),
                    removal: .move(edge: .bottom).combined(with: .opacity).animation(.easeInOut(duration: 0.3))
                ))
            } else {
                HStack {
                    Label {
                        Text("운동 시간")
                            .font(.caption)
                    } icon: {
                        Image(systemName: "stopwatch")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("시작: \(formattedStartTime)")
                        .font(.caption)
                        .foregroundColor(.blue.opacity(0.7))
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity).animation(.easeInOut(duration: 0.3)),
                    removal: .move(edge: .bottom).combined(with: .opacity).animation(.easeInOut(duration: 0.3))
                ))
            }
        }
        .animation(.smooth, value: context.state.isRestMode)
    }
    
    private var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: context.state.startTime)
    }
}
