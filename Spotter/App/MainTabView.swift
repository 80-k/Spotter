// MainTabView.swift
// 메인 탭 뷰 컴포넌트
// Created by woo on 3/31/25.

import SwiftUI
import GoogleSignIn

/// 메인 탭 열거형
enum MainTab {
    case history
    case start
    case settings
}

/// 메인 탭 뷰
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: MainTab = .start // 기본 선택 탭을 '시작'으로 설정
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 기록 탭
            WorkoutHistoryTabView(modelContext: modelContext)
                .tabItem {
                    Label("기록", systemImage: "list.bullet.clipboard")
                }
                .tag(MainTab.history)
            
            // 시작 탭
            WorkoutTemplateListView(modelContext: modelContext)
                .tabItem {
                    Label("시작", systemImage: "play.circle")
                }
                .tag(MainTab.start)
            
            // 설정 탭 추가
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape")
                }
                .tag(MainTab.settings)
        }
        .onOpenURL { url in
            // Google 로그인 콜백 URL 처리
            GIDSignIn.sharedInstance.handle(url)
        }
    }
} 