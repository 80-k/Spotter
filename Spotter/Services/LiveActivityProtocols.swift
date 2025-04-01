// LiveActivityProtocols.swift
// 라이브 액티비티 관련 프로토콜 및 타입 정의
// Created by woo on 4/1/25.

import Foundation
import ActivityKit

// 라이브 액티비티 관리자 인터페이스
protocol LiveActivityManaging {
    // 상태 관리
    func reset()
    func endActivity()
    
    // 기본 작업
    func startActivity(workoutName: String, startTime: Date)
    func updateElapsedTime()
    
    // 휴식 타이머 관련
    func updateRestTimer(exerciseName: String, remainingTime: Int)
    func switchToWorkoutMode(immediate: Bool)
    
    // 앱 상태 관련
    func handleAppBackgroundTransition()
    
    // 디버깅 
    func logCurrentState()
}

// 활동 모드 열거형
enum ActivityMode: CustomStringConvertible {
    case none           // 활동 없음
    case workout        // 일반 운동 모드
    case restTimer      // 휴식 타이머 모드
    
    var description: String {
        switch self {
        case .none:
            return "없음"
        case .workout:
            return "운동 모드"
        case .restTimer:
            return "휴식 타이머 모드"
        }
    }
}

// 업데이트 간격 설정
struct ActivityUpdateIntervals {
    static let regular: TimeInterval = 0.5    // 일반 업데이트
    static let transition: TimeInterval = 0.1 // 모드 전환용
}

// 활동 업데이터 프로토콜
protocol ActivityUpdating {
    func createActivity(workoutName: String, startTime: Date) -> Activity<WorkoutActivityAttributes>?
    func updateActivity(_ activity: Activity<WorkoutActivityAttributes>, startTime: Date, elapsedTime: TimeInterval) async
    func endActivity(_ activity: Activity<WorkoutActivityAttributes>) async
} 