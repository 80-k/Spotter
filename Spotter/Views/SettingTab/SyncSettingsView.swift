// SyncSettingsView.swift
// 동기화 설정 UI 컴포넌트
// Created by woo on 3/30/25.

import SwiftUI

// 동기화 설정 뷰
struct SyncSettingsView: View {
    @ObservedObject var syncManager = DataSyncManager.shared
    @ObservedObject var authManager = AuthManager.shared
    
    @AppStorage("data_sync_auto_enabled") private var autoSyncEnabled = true
    @AppStorage("data_sync_interval") private var syncInterval = "매일"
    
    var body: some View {
        VStack(spacing: 0) {
            // 현재 상태 표시
            SyncStatusView()
                .padding(.bottom, 16)
            
            // 설정 섹션
            if authManager.isLoggedIn {
                // 자동 동기화 설정
                Toggle("자동 동기화", isOn: $autoSyncEnabled)
                    .onChange(of: autoSyncEnabled) { _, newValue in
                        syncManager.updateSyncSettings(autoSync: newValue, interval: syncInterval)
                    }
                
                if autoSyncEnabled {
                    // 동기화 주기 설정
                    Picker("동기화 주기", selection: $syncInterval) {
                        Text("매일").tag("매일")
                        Text("매주").tag("매주")
                        Text("매월").tag("매월")
                        Text("수동").tag("수동")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, 8)
                    .onChange(of: syncInterval) { _, newValue in
                        syncManager.updateSyncSettings(autoSync: autoSyncEnabled, interval: newValue)
                    }
                }
                
                // 추가 동기화 설정
                VStack(alignment: .leading, spacing: 16) {
                    // 로그 내보내기 (개발/디버깅용)
                    Button {
                        if let logUrl = syncManager.exportSyncLogs() {
                            print("로그 파일 생성됨: \(logUrl.path)")
                        }
                    } label: {
                        Label("동기화 로그 내보내기", systemImage: "square.and.arrow.up")
                            .font(.footnote)
                    }
                }
                .padding(.top, 16)
            } else {
                // 로그인되지 않은 경우 안내 메시지
                NotLoggedInView()
            }
        }
    }
}

// 로그인되지 않은 경우 표시하는 뷰
struct NotLoggedInView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            
            Text("데이터 동기화를 사용하려면 계정에 로그인하세요.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
