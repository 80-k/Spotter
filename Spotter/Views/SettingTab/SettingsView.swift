//
//  SettingsView.swift
//  Spotter - 앱 설정 화면 (통합 로그인 기능 추가)
//  Created by woo on 3/30/25.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    // 테마 관리자
    @Environment(\.themeManager) private var themeManager
    // 선택된 테마를 위한 상태 변수
    @State private var selectedTheme: AppTheme = .system
    
    // 통합 인증 관리자
    @ObservedObject private var authManager = AuthManager.shared
    
    // 프로필 화면 이동 상태
    @State private var showingProfileView = false
    
    // 로그인 시트 표시 상태
    @State private var showingLoginSheet = false
    
    var body: some View {
        NavigationStack {
            Form {
                // 계정 섹션
                Section(header: Text("계정")) {
                    if authManager.isLoggedIn {
                        // 로그인된 경우 - 사용자 정보 표시
                        Button(action: {
                            showingProfileView = true
                        }) {
                            HStack {
                                // 프로필 이미지 (URL이 있는 경우 로드)
                                ProfileImageView(
                                    imageURL: authManager.profileImageURL,
                                    placeholderImage: "person.crop.circle.fill",
                                    size: 40
                                )
                                .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(authManager.userName.isEmpty ? "사용자" : authManager.userName)
                                        .font(.headline)
                                    
                                    if !authManager.userEmail.isEmpty {
                                        Text(authManager.userEmail)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Text("프로필 관리")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        
                                        // 로그인 제공자 표시
                                        if authManager.authProvider != .none {
                                            Text("(\(authManager.authProvider.rawValue))")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.top, 2)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        // 로그인되지 않은 경우 - 로그인 버튼 표시
                        VStack(alignment: .leading, spacing: 12) {
                            Text("계정 연결")
                                .font(.headline)
                            
                            Text("운동 기록을 클라우드에 백업하고 여러 기기에서 동기화할 수 있습니다.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // 로그인 버튼 그룹
                            VStack(spacing: 10) {
                                // Apple 로그인 버튼
                                AppleSignInButton()
                                
                                // Google 로그인 버튼
                                GoogleSignInButtonAlt()
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
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
                    
                    // 현재 테마 정보
                    HStack {
                        Label("현재 테마", systemImage: themeManager.currentTheme.icon)
                            .foregroundColor(themeIconColor(for: themeManager.currentTheme))
                        
                        Spacer()
                        
                        Text(themeManager.currentTheme.name)
                            .foregroundColor(.secondary)
                    }
                    
                    // 테마 토글 버튼
                    HStack {
                        Text("테마 전환")
                        
                        Spacer()
                        
                        ThemeToggleButton()
                    }
                }
                
                // 동기화 및 백업 섹션 (로그인 시만 표시)
                if authManager.isLoggedIn {
                    Section(header: Text("동기화 및 백업")) {
                        Toggle("자동 백업", isOn: .constant(true))
                        
                        Picker("동기화 주기", selection: .constant("매일")) {
                            Text("매일").tag("매일")
                            Text("매주").tag("매주")
                            Text("수동").tag("수동")
                        }
                        
                        Button(action: {
                            // 수동 백업 실행 액션
                        }) {
                            Label("지금 백업", systemImage: "arrow.clockwise.icloud")
                        }
                    }
                }
                
                // 알림 설정
                Section(header: Text("알림 설정")) {
                    Toggle("운동 알림", isOn: .constant(true))
                    Toggle("휴식 타이머 알림", isOn: .constant(true))
                    Toggle("목표 달성 알림", isOn: .constant(true))
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
                    
                    // 개인정보처리방침
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Label("개인정보처리방침", systemImage: "hand.raised.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("설정")
            .onAppear {
                // 뷰가 나타날 때 현재 테마 로드
                selectedTheme = themeManager.currentTheme
            }
            .sheet(isPresented: $showingProfileView) {
                UserProfileView()
            }
            .sheet(isPresented: $showingLoginSheet) {
                // 로그인 선택 화면
                VStack {
                    AuthButtonsView()
                }
                .presentationDetents([.medium])
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
