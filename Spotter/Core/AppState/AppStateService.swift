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
    
    // 콜백 함수
    var onBackgrounded: (() -> Void)?
    var onForegrounded: (() -> Void)?
    
    // 초기화
    private init() {}
    
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
            onBackgrounded?()
        }
        
        // 포그라운드로 복귀 (백그라운드 → 활성 또는 백그라운드 → 비활성 → 활성)
        if oldPhase == .background && (phase == .active || phase == .inactive) {
            print("앱이 포그라운드로 복귀함")
            onForegrounded?()
        }
    }
} 