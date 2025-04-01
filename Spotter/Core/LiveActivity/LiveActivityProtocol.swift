// LiveActivityProtocol.swift
// 라이브 액티비티 서비스 프로토콜
//  Created by woo on 3/30/25.

import Foundation
import SwiftData

/// 라이브 액티비티 서비스 프로토콜
protocol LiveActivityServiceProtocol {
    /// 운동 활동 시작
    func startWorkoutActivity(for session: WorkoutSession)
    
    /// 운동 활동 업데이트
    func updateWorkoutActivity(for session: WorkoutSession)
    
    /// 휴식 타이머 활동 시작
    func startRestTimerActivity(for set: WorkoutSet)
    
    /// 휴식 타이머 업데이트
    func updateRestTimerActivity(for set: WorkoutSet)
    
    /// 활동 종료
    func endActivity()
    
    /// 앱이 백그라운드로 전환될 때 처리
    func handleAppBackgroundTransition()
} 