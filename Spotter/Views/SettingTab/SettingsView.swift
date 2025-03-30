//
//  SettingsView.swift
//  Spotter - 앱 설정 화면
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct SettingsView: View {
    // 테마 관리자
    @Environment(\.themeManager) private var themeManager
    // 선택된 테마를 위한 상태 변수
    @State private var selectedTheme: AppTheme = .system
    
    var body: some View {
        NavigationStack {
            Form {
                // 테마 설정 섹션
                Section(header: Text("테마 설정")) {
                    // 테마 픽커
                    Picker("테마", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            HStack {
                                Image(systemName: theme.icon)
                                    .foregroundColor(themeIconColor(for: theme))
                                Text(theme.name)
                            }
                            .tag(theme)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: selectedTheme) { _, newValue in
                        themeManager.setTheme(newValue)
                    }
                }
                
                // 앱 정보 섹션
                Section(header: Text("앱 정보")) {
                    // 앱 버전
                    HStack {
                        Label("버전", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    // 제작자 정보
                    HStack {
                        Label("개발자", systemImage: "person.fill")
                        Spacer()
                        Text("woo")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("설정")
            .onAppear {
                // 뷰가 나타날 때 현재 테마 로드
                selectedTheme = themeManager.currentTheme
            }
        }
    }
    
    // 테마 아이콘 색상
    private func themeIconColor(for theme: AppTheme) -> Color {
        switch theme {
        case .system:
            return .blue
        case .light:
            return .orange
        case .dark:
            return .indigo
        }
    }
    
    // 앱 버전 정보
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return "1.0"
    }
}

#Preview {
    SettingsView()
}
