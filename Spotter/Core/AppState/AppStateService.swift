// AppStateService.swift
// 앱 상태 관리 서비스 구현
//  Created by woo on 3/31/25.

import Foundation
import SwiftUI

/// 앱 상태 관리 서비스
final class AppStateService: ObservableObject, AppStateServiceProtocol {
    // 싱글톤 인스턴스
    static let shared = AppStateService()
    
    // 현재 씬 단계
    @Published private(set) var currentScenePhase: ScenePhase = .inactive
    
    // 이전 씬 단계
    private var previousScenePhase: ScenePhase = .inactive
    
    // 활성화된 운동 뷰모델 참조 (약한 참조로 유지)
    private weak var activeWorkoutViewModel: WorkoutViewModelManageable?
    
    // 휴식 타이머 서비스
    private let restTimerService = RestTimerService.shared
    
    // 콜백 함수
    var onBackgrounded: (() -> Void)?
    var onForegrounded: (() -> Void)?
    
    // 초기화
    private init() {}
    
    /// 활성 운동 뷰모델 설정
    func registerActiveWorkoutViewModel(_ viewModel: WorkoutViewModelManageable) {
        activeWorkoutViewModel = viewModel
        print("AppStateService: 활성 운동 뷰모델 등록됨")
    }
    
    /// 활성 운동 뷰모델 제거
    func unregisterActiveWorkoutViewModel() {
        activeWorkoutViewModel = nil
        print("AppStateService: 활성 운동 뷰모델 등록 해제됨")
    }
    
    /// 씬 단계 업데이트
    func updateScenePhase(_ phase: ScenePhase) {
        // 이전 단계 저장
        let oldPhase = currentScenePhase
        previousScenePhase = oldPhase
        
        // 현재 단계 업데이트
        currentScenePhase = phase
        
        // 백그라운드로 전환
        if oldPhase != .background && phase == .background {
            print("앱이 백그라운드로 전환됨")
            
            // 활성 운동 뷰모델 처리
            activeWorkoutViewModel?.handleAppStateChange(toBackground: true)
            
            // 휴식 타이머 처리
            restTimerService.handleAppBackgrounded()
            
            // 콜백 호출
            onBackgrounded?()
        }
        
        // 포그라운드로 복귀 (백그라운드 → 활성 또는 백그라운드 → 비활성 → 활성)
        if oldPhase == .background && (phase == .active || phase == .inactive) {
            print("앱이 포그라운드로 복귀함")
            
            // 활성 운동 뷰모델 처리
            activeWorkoutViewModel?.handleAppStateChange(toBackground: false)
            
            // 휴식 타이머 처리
            restTimerService.handleAppForegrounded()
            
            // 콜백 호출
            onForegrounded?()
        }
    }
} 