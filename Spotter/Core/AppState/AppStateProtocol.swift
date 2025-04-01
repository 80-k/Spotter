// AppStateProtocol.swift
// 앱 상태 관리 프로토콜
//  Created by woo on 3/31/25.

import Foundation
import SwiftUI

/// 앱 상태에서 관리할 수 있는 워크아웃 뷰모델 프로토콜
protocol WorkoutViewModelManageable: AnyObject {
    /// 앱 상태 변경 처리
    func handleAppStateChange(toBackground: Bool)
    
    /// 앱이 백그라운드로 전환될 때 호출
    func handleAppBackgrounded()
    
    /// 앱이 포그라운드로 돌아올 때 호출
    func handleAppForegrounded()
}

/// 앱 상태 관리 프로토콜
protocol AppStateServiceProtocol: AnyObject {
    /// 현재 씬 단계
    var currentScenePhase: ScenePhase { get }
    
    /// 앱이 백그라운드로 전환될 때 호출될 콜백
    var onBackgrounded: (() -> Void)? { get set }
    
    /// 앱이 포그라운드로 돌아올 때 호출될 콜백
    var onForegrounded: (() -> Void)? { get set }
    
    /// 씬 단계 업데이트
    func updateScenePhase(_ phase: ScenePhase)
    
    /// 활성 운동 뷰모델 등록
    func registerActiveWorkoutViewModel(_ viewModel: WorkoutViewModelManageable)
    
    /// 활성 운동 뷰모델 등록 해제
    func unregisterActiveWorkoutViewModel()
} 