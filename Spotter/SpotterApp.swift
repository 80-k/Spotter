// SpotterApp.swift
// Spotter 앱 - 테마 시스템 및 온보딩 통합 + 앱 상태 관리
//  Created by woo on 3/30/25.

import SwiftUI
import SwiftData
import GoogleSignIn
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct SpotterApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // 테마 관리자
    @StateObject private var themeManager = ThemeManager.shared
    
    // 앱 상태 관리자
    @StateObject private var appStateManager = AppStateManager.shared
    
    // 온보딩 완료 여부 확인
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // 현재 씬 단계 감지
    @Environment(\.scenePhase) private var scenePhase
    
    // 데이터 모델 컨테이너 정의
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ExerciseItem.self,
            WorkoutTemplate.self,
            WorkoutSession.self,
            WorkoutSet.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("모델 컨테이너 생성 실패: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasCompletedOnboarding {
                    // 메인 앱 화면
                    MainTabView()
                        // 테마 설정 적용
                        .preferredColorScheme(themeManager.currentTheme.colorScheme)
                        // 테마 관리자를 환경에 제공
                        .environment(\.themeManager, themeManager)
                        // 앱 상태 관리자를 환경에 제공
                        .environment(\.appState, appStateManager)
                } else {
                    // 온보딩 화면
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
            }
            .modelContainer(sharedModelContainer)
            .onChange(of: scenePhase) { _, newPhase in
                appStateManager.updateScenePhase(newPhase)
            }
        }
    }
}

// 메인 탭 뷰
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            // 기록 탭
            WorkoutHistoryTabView(modelContext: modelContext)
                .tabItem {
                    Label("기록", systemImage: "list.bullet.clipboard")
                }
            
            // 시작 탭
            WorkoutTemplateListView(modelContext: modelContext)
                .tabItem {
                    Label("시작", systemImage: "play.circle")
                }
            
            // 설정 탭 추가
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape")
                }
        }
        .onOpenURL { url in
            // Google 로그인 콜백 URL 처리
            GIDSignIn.sharedInstance.handle(url)
        }
    }
}
