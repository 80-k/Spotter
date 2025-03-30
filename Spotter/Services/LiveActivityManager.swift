// LiveActivityManager.swift
// 다이나믹 아일랜드 라이브 액티비티 관리
// Created by woo on 3/29/25.

import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<WorkoutActivityAttributes>?
    
    private init() {}
    
    // 운동 라이브 액티비티 시작
    func startActivity(workoutName: String, startTime: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("라이브 액티비티가 활성화되지 않았습니다.")
            return
        }
        
        let attributes = WorkoutActivityAttributes(workoutName: workoutName)
        let contentState = WorkoutActivityAttributes.ContentState(
            startTime: startTime,
            elapsedTime: 0,
            isRestTimer: false,
            restExerciseName: "",
            restTimeRemaining: 0
        )
        
        do {
            // ActivityContent 객체를 명시적으로 생성하여 전달
            let initialContent = ActivityContent(state: contentState, staleDate: nil)
            
            currentActivity = try Activity.request(
                attributes: attributes,
                content: initialContent,
                pushType: nil
            )
            print("운동 라이브 액티비티 시작: \(workoutName)")
        } catch {
            print("라이브 액티비티 시작 실패: \(error)")
        }
    }
    
    // 휴식 타이머 업데이트
    func updateRestTimer(exerciseName: String, remainingTime: Int) {
        // 액티비티가 없으면 새로 시작
        if currentActivity == nil {
            startRestTimerActivity(exerciseName: exerciseName, remainingTime: remainingTime)
            return
        }
        
        guard let activity = currentActivity else { return }
        
        let updatedState = WorkoutActivityAttributes.ContentState(
            startTime: activity.content.state.startTime,
            elapsedTime: Date().timeIntervalSince(activity.content.state.startTime),
            isRestTimer: true,
            restExerciseName: exerciseName,
            restTimeRemaining: remainingTime
        )
        
        // ActivityContent 객체를 명시적으로 생성하여 전달
        let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(updatedContent)
        }
    }
    
    func startRestTimerActivity(exerciseName: String, remainingTime: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("라이브 액티비티가 활성화되지 않았습니다.")
            return
        }
        
        let attributes = WorkoutActivityAttributes(workoutName: exerciseName)
        let contentState = WorkoutActivityAttributes.ContentState(
            startTime: Date(),
            elapsedTime: 0,
            isRestTimer: true,
            restExerciseName: exerciseName,
            restTimeRemaining: remainingTime
        )
        
        do {
            // ActivityContent 객체를 명시적으로 생성하여 전달
            let initialContent = ActivityContent(state: contentState, staleDate: nil)
            
            currentActivity = try Activity.request(
                attributes: attributes,
                content: initialContent,
                pushType: nil
            )
            print("휴식 타이머 라이브 액티비티 시작: \(exerciseName)")
        } catch {
            print("라이브 액티비티 시작 실패: \(error)")
        }
    }
    
    // 운동 시간 업데이트
    func updateElapsedTime() {
        guard let activity = currentActivity else { return }
        
        let updatedState = WorkoutActivityAttributes.ContentState(
            startTime: activity.content.state.startTime,
            elapsedTime: Date().timeIntervalSince(activity.content.state.startTime),
            isRestTimer: activity.content.state.isRestTimer,
            restExerciseName: activity.content.state.restExerciseName,
            restTimeRemaining: activity.content.state.restTimeRemaining
        )
        
        // ActivityContent 객체를 명시적으로 생성하여 전달
        let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(updatedContent)
        }
    }
    
    // 운동 라이브 액티비티 종료
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        let finalState = WorkoutActivityAttributes.ContentState(
            startTime: activity.content.state.startTime,
            elapsedTime: Date().timeIntervalSince(activity.content.state.startTime),
            isRestTimer: false,
            restExerciseName: "",
            restTimeRemaining: 0
        )
        
        // ActivityContent 객체를 명시적으로 생성하여 전달
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        
        Task {
            await activity.end(finalContent, dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}
