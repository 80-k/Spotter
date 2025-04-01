// WorkoutActivityUpdater.swift
// 운동 라이브 액티비티 업데이트 담당 클래스
// Created by woo on 4/1/25.

import Foundation
import ActivityKit

// 로깅 카테고리 상수
private let logCategory = "WorkoutActivityUpdater"

// 운동 모드 업데이트
final class WorkoutActivityUpdater: ActivityUpdating {
    // 액티비티 생성
    func createActivity(workoutName: String, startTime: Date) -> Activity<WorkoutActivityAttributes>? {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            spotterLog("라이브 액티비티가 활성화되지 않았습니다.", level: .error, category: logCategory)
            return nil
        }
        
        let attributes = WorkoutActivityAttributes(workoutName: workoutName)
        let contentState = WorkoutActivityAttributes.ContentState(
            startTime: startTime,
            exerciseCount: 0,
            completedSets: 0,
            totalSets: 0,
            isRestMode: false,
            restExerciseName: "",
            remainingRestTime: 0
        )
        
        do {
            let initialContent = ActivityContent(state: contentState, staleDate: nil)
            let activity = try Activity.request(
                attributes: attributes,
                content: initialContent,
                pushType: nil
            )
            
            spotterLog("운동 라이브 액티비티 시작: \(workoutName)", level: .debug, category: logCategory)
            return activity
        } catch {
            spotterLog("라이브 액티비티 시작 실패: \(error.localizedDescription)", level: .error, category: logCategory)
            return nil
        }
    }
    
    // 액티비티 업데이트
    func updateActivity(_ activity: Activity<WorkoutActivityAttributes>, startTime: Date, elapsedTime: TimeInterval) async {
        let updatedState = WorkoutActivityAttributes.ContentState(
            startTime: startTime,
            exerciseCount: 0,
            completedSets: 0,
            totalSets: 0,
            isRestMode: false,
            restExerciseName: "",
            remainingRestTime: 0
        )
        
        let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
        await activity.update(updatedContent)
        spotterLog("운동 모드 라이브 액티비티 업데이트 성공", level: .debug, category: logCategory)
    }
    
    // 액티비티 종료
    func endActivity(_ activity: Activity<WorkoutActivityAttributes>) async {
        let finalContent = ActivityContent(
            state: WorkoutActivityAttributes.ContentState(
                startTime: Date(),
                exerciseCount: 0,
                completedSets: 0,
                totalSets: 0,
                isRestMode: false,
                restExerciseName: "",
                remainingRestTime: 0
            ),
            staleDate: nil
        )
        await activity.end(finalContent, dismissalPolicy: .immediate)
        spotterLog("운동 라이브 액티비티 종료 완료", level: .debug, category: logCategory)
    }
} 
