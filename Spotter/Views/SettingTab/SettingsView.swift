//
//  SettingsView.swift
//  Spotter - 앱 설정 화면 (Apple ID 로그인 및 프로필 이동 추가)
//
//  Created by woo on 3/30/25.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    // 테마 관리자
    @Environment(\.themeManager) private var themeManager
    // 선택된 테마를 위한 상태 변수
    @State private var selectedTheme: AppTheme = .system
    
    // Apple 로그인 관리자
    @ObservedObject private var signInManager = AppleSignInManager.shared
    
    // 프로필 화면 이동 상태
    @State private var showingProfileView = false
    
    var body: some View {
        NavigationStack {
            Form {
                // 계정 섹션
                Section(header: Text("계정")) {
                    if signInManager.isLoggedIn {
                        // 로그인된 경우 - 사용자 정보 표시
                        Button(action: {
                            showingProfileView = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(signInManager.userName.isEmpty ? "사용자" : signInManager.userName)
                                        .font(.headline)
                                    
                                    if !signInManager.userEmail.isEmpty {
                                        Text(signInManager.userEmail)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("프로필 관리")
                                        .font(.caption)
                                        .foregroundColor(.blue)
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
                            Text("Apple ID로 로그인")
                                .font(.headline)
                            
                            Text("운동 기록을 클라우드에 백업하고 여러 기기에서 동기화할 수 있습니다.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            AppleSignInButton()
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
