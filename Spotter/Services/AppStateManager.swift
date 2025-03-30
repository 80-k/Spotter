// AppStateManager.swift
// 앱 상태 관리 (백그라운드/포그라운드 전환) 컴포넌트
//  Created by woo on 3/30/25.

import Foundation
import SwiftUI
import Combine

class AppStateManager: ObservableObject {
    // 싱글톤 인스턴스
    static let shared = AppStateManager()
    
    // 현재 앱 상태
    @Published var scenePhase: ScenePhase = .active
    
    // 백그라운드 전환 관련 시간 정보
    @Published var lastBackgroundedTime: Date?
    @Published var lastForegroundedTime: Date?
    
    // 현재 백그라운드/포그라운드 상태
    @Published var isInBackground: Bool = false
    
    // 앱 시작 시간
    let appStartTime: Date
    
    // 앱 상태 변경 시 호출될 콜백
    var onBackgrounded: (() -> Void)?
    var onForegrounded: (() -> Void)?
    
    // 구독 보관
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        appStartTime = Date()
    }
    
    // ScenePhase 업데이트를 처리하는 메서드
    func updateScenePhase(_ newPhase: ScenePhase) {
        let oldPhase = scenePhase
        scenePhase = newPhase
        
        switch newPhase {
        case .background:
            lastBackgroundedTime = Date()
            isInBackground = true
            
            // 콜백 호출
            onBackgrounded?()
            
            print("[AppState] 앱이 백그라운드로 전환됨: \(lastBackgroundedTime?.formatted() ?? "unknown")")
            
        case .active:
            if oldPhase == .background {
                lastForegroundedTime = Date()
                isInBackground = false
                
                // 콜백 호출
                onForegrounded?()
                
                if let lastBackground = lastBackgroundedTime {
                    let timeInBackground = Date().timeIntervalSince(lastBackground)
                    print("[AppState] 앱이 포그라운드로 복귀함. 백그라운드에 \(timeInBackground)초 있었음")
                } else {
                    print("[AppState] 앱이 포그라운드로 복귀함")
                }
            }
            
        default:
            break
        }
    }
    
    // 앱 실행 시간을 계산하는 메서드
    var appRunningTime: TimeInterval {
        return Date().timeIntervalSince(appStartTime)
    }
    
    // 마지막 백그라운드 전환 후 경과 시간
    var timeSinceLastBackgrounded: TimeInterval? {
        guard let lastTime = lastBackgroundedTime else { return nil }
        return Date().timeIntervalSince(lastTime)
    }
    
    // 마지막 포그라운드 전환 후 경과 시간
    var timeSinceLastForegrounded: TimeInterval? {
        guard let lastTime = lastForegroundedTime else { return nil }
        return Date().timeIntervalSince(lastTime)
    }
    
    // 백그라운드에 있었던 시간 계산
    func calculateBackgroundDuration() -> TimeInterval? {
        guard let backgroundTime = lastBackgroundedTime,
              let foregroundTime = lastForegroundedTime,
              foregroundTime > backgroundTime else {
            return nil
        }
        
        return foregroundTime.timeIntervalSince(backgroundTime)
    }
}

// SwiftUI 뷰에서 쉽게 사용할 수 있는 환경 키
struct AppStateKey: EnvironmentKey {
    static let defaultValue = AppStateManager.shared
}

extension EnvironmentValues {
    var appState: AppStateManager {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}
