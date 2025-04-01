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
    
    // LiveActivity 서비스 
    private let liveActivityService = LiveActivityService.shared
    
    // 백그라운드 진입 시간 추적
    @State private var backgroundEntryTime: Date? = nil
    
    // 백그라운드 타임아웃 (10초 후 LiveActivity 종료)
    private let backgroundTimeout: TimeInterval = 10
    
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
                
                // 앱이 백그라운드로 전환될 때 처리
                if newPhase == .background {
                    print("SpotterApp: 백그라운드 전환 감지")
                    handleAppBackgrounded()
                } else if newPhase == .active {
                    // 앱이 포그라운드로 돌아올 때 처리
                    handleAppForegrounded()
                }
            }
            .onAppear {
                // 앱 상태 콜백 설정 - 뷰가 나타난 후 실행
                setupAppStateCallbacks()
                
                // 앱 종료 감지를 위한 알림 관찰자 등록
                setupAppTerminationObserver()
            }
        }
    }
    
    // 앱 종료 감지 옵저버 설정
    private func setupAppTerminationObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main) { _ in
                print("SpotterApp: 앱 종료 감지")
                
                // 앱 종료 시 LiveActivity 완전히 종료
                LiveActivityService.shared.endAllActivities()
                
                // 휴식 타이머 정리
                RestTimerService.shared.stopTimer()
            }
    }
    
    // 앱이 백그라운드로 전환될 때 호출
    private func handleAppBackgrounded() {
        // 백그라운드 진입 시간 기록
        backgroundEntryTime = Date()
        
        // LiveActivity 처리
        LiveActivityService.shared.handleAppBackgroundTransition()
        
        // 휴식 타이머 처리
        restTimerService.handleAppBackgrounded()
        
        // 일정 시간 후 LiveActivity 종료를 위한 백그라운드 작업 예약
        Task {
            do {
                // 10초 동안 대기 (앱이 종료되었다고 간주할 시간)
                try await Task.sleep(for: .seconds(backgroundTimeout))
                
                // 앱이 여전히 백그라운드 상태이고 충분한 시간이 지났다면 LiveActivity 종료
                if scenePhase == .background, 
                   let entryTime = backgroundEntryTime,
                   Date().timeIntervalSince(entryTime) >= backgroundTimeout {
                    print("SpotterApp: 장시간 백그라운드 상태로 LiveActivity 종료")
                    
                    // LiveActivity 완전히 종료
                    LiveActivityService.shared.endAllActivities()
                    
                    // 휴식 타이머 정리
                    restTimerService.stopTimer()
                }
            } catch {
                print("백그라운드 작업 오류: \(error)")
            }
        }
    }
    
    // 앱이 포그라운드로 돌아올 때 호출
    private func handleAppForegrounded() {
        // 백그라운드 진입 시간 초기화
        backgroundEntryTime = nil
        
        // 휴식 타이머 처리
        restTimerService.handleAppForegrounded()
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