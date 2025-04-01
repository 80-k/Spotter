// RestTimerProtocol.swift
// 휴식 타이머 관리를 위한 프로토콜
//  Created by woo on 3/31/25.

import Foundation
import SwiftUI

/// 휴식 타이머 관리 프로토콜
protocol RestTimerProtocol {
    /// 휴식 타이머 시작
    func startTimer(for set: WorkoutSet, viewModel: ActiveWorkoutViewModel)
    
    /// 휴식 타이머 중지
    func stopTimer()
    
    /// 앱이 백그라운드로 전환될 때 호출
    func handleAppBackgrounded()
    
    /// 앱이 포그라운드로 돌아올 때 호출
    func handleAppForegrounded()
    
    /// 현재 타이머가 활성 상태인지 여부
    var isActive: Bool { get }
    
    /// 현재 활성 세트
    var currentActiveSet: WorkoutSet? { get }
}