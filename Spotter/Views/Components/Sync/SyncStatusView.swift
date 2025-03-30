// SyncStatusView.swift
// 동기화 상태 UI 컴포넌트
// Created by woo on 3/30/25.

import SwiftUI

// 동기화 상태 표시 뷰
struct SyncStatusView: View {
    @ObservedObject var syncManager = DataSyncManager.shared
    
    var body: some View {
        HStack(spacing: 8) {
            // 상태 아이콘
            statusIcon
                .foregroundColor(statusColor)
            
            // 상태 텍스트
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // 수동 동기화 버튼
            if syncManager.syncStatus != .syncing {
                Button(action: {
                    syncManager.startSync()
                }) {
                    Label("지금 동기화", systemImage: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .disabled(!syncManager.isOnline || syncManager.syncStatus == .syncing)
            } else {
                // 진행 중인 경우 진행률 표시
                ProgressView(value: syncManager.syncProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 60)
            }
        }
        .padding(.vertical, 8)
    }
    
    // 상태에 따른 아이콘
    private var statusIcon: Image {
        switch syncManager.syncStatus {
        case .idle:
            return Image(systemName: "circle.dashed")
        case .syncing:
            return Image(systemName: "arrow.triangle.2.circlepath")
        case .completed:
            return Image(systemName: "checkmark.circle.fill")
        case .failed:
            return Image(systemName: "exclamationmark.triangle.fill")
        case .offline:
            return Image(systemName: "wifi.slash")
        }
    }
    
    // 상태에 따른 색상
    private var statusColor: Color {
        switch syncManager.syncStatus {
        case .idle, .syncing:
            return .blue
        case .completed:
            return .green
        case .failed, .offline:
            return .orange
        }
    }
    
    // 상태에 따른 텍스트
    private var statusText: String {
        switch syncManager.syncStatus {
        case .idle:
            return "동기화 대기 중"
        case .syncing:
            return "동기화 중..."
        case .completed:
            if let lastSync = syncManager.lastSyncTime {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .short
                return "마지막 동기화: \(formatter.localizedString(for: lastSync, relativeTo: Date()))"
            } else {
                return "동기화 완료"
            }
        case .failed:
            return "동기화 실패"
        case .offline:
            return "오프라인 상태"
        }
    }
}
