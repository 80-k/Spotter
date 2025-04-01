// SpotterApp.swift
// Spotter 앱 - 앱 진입점
//  Created by woo on 3/30/25.

import SwiftUI
import SwiftData

@main
struct SpotterApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // 테마 서비스
    @StateObject private var themeService = ThemeService.shared
    
    // 앱 상태 서비스
    @StateObject private var appStateService = AppStateService.shared
    
    // 온보딩 완료 여부 확인
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // 현재 씬 단계 감지
    @Environment(\.scenePhase) private var scenePhase
    
    // 모델 컨테이너
    private let swiftDataManager = SwiftDataManager.shared
    
    // 휴식 타이머 서비스 참조 추가
    private let restTimerService = RestTimerService.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasCompletedOnboarding {
                    // 메인 앱 화면
                    MainTabView()
                        // 테마 설정 적용
                        .preferredColorScheme(themeService.currentTheme.colorScheme)
                        // 테마 서비스를 환경에 제공
                        .environment(\.themeService, themeService)
                        // 앱 상태 서비스를 환경에 제공
                        .environment(\.appState, appStateService)
                } else {
                    // 온보딩 화면
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
            }
            .modelContainer(swiftDataManager.sharedModelContainer)
            .observeScenePhase() // ScenePhase 변경 이벤트를 NotificationCenter로 발행
            .onChange(of: scenePhase) { _, newPhase in
                appStateService.updateScenePhase(newPhase)
                
                // 앱이 백그라운드로 전환될 때 LiveActivity 처리
                if newPhase == .background {
                    print("SpotterApp: 백그라운드 전환 감지")
                    LiveActivityService.shared.handleAppBackgroundTransition()
                    
                    // 백그라운드 전환 시 휴식 타이머 상태 처리
                    restTimerService.handleAppBackgrounded()
                } else if newPhase == .active {
                    // 포그라운드로 돌아올 때 처리
                    restTimerService.handleAppForegrounded()
                }
            }
            .onAppear {
                // 앱 상태 콜백 설정 - 뷰가 나타난 후 실행
                setupAppStateCallbacks()
            }
        }
    }
    
    // 앱 상태 콜백 설정
    private func setupAppStateCallbacks() {
        // 앱 상태 서비스가 초기화된 후에만 콜백 설정
        // 앱이 백그라운드로 전환될 때 콜백
        appStateService.onBackgrounded = {
            print("SpotterApp: 백그라운드 콜백 실행")
            // 휴식 타이머 백그라운드 처리
            RestTimerService.shared.handleAppBackgrounded()
        }
        
        // 앱이 포그라운드로 돌아올 때 콜백
        appStateService.onForegrounded = {
            print("SpotterApp: 포그라운드 콜백 실행")
            // 휴식 타이머 포그라운드 처리
            RestTimerService.shared.handleAppForegrounded()
        }
    }
} 