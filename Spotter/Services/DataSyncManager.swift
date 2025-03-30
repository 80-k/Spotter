//
//  DataSyncManager.swift
//  Spotter - 데이터 동기화 관리
//
//  Created by woo on 3/30/25.
//

import Foundation
import SwiftData
import Combine
import Network

// 동기화 상태 열거형
enum SyncStatus {
    case idle        // 대기 중
    case syncing     // 동기화 중
    case completed   // 완료됨
    case failed      // 실패
    case offline     // 오프라인
}

// 데이터 동기화 관리 클래스
class DataSyncManager: ObservableObject {
    // 싱글톤 인스턴스
    static let shared = DataSyncManager()
    
    // 현재 동기화 상태
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncTime: Date?
    @Published var syncProgress: Double = 0.0
    
    // 네트워크 상태 모니터링
    private let networkMonitor = NWPathMonitor()
    @Published var isOnline: Bool = false
    
    // 인증 관리자
    private let authManager = AuthManager.shared
    
    // 동기화 주기 설정 (기본값: 하루)
    private var syncInterval: TimeInterval = 24 * 60 * 60
    
    // 동기화 작업 취소용 토큰
    private var syncCancellable: AnyCancellable?
    
    // 백그라운드 동기화 작업 식별자
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    private init() {
        // 네트워크 상태 모니터링 시작
        setupNetworkMonitoring()
        
        // 인증 상태 변경 감지
        authManager.$isLoggedIn
            .sink { [weak self] isLoggedIn in
                if isLoggedIn {
                    // 로그인 시 동기화 시작
                    self?.scheduleSync()
                } else {
                    // 로그아웃 시 동기화 취소
                    self?.cancelScheduledSync()
                }
            }
            .store(in: &cancellables)
    }
    
    // 취소 토큰 저장
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 공개 메서드
    
    // 수동 동기화 시작
    func startSync() {
        guard authManager.isLoggedIn, isOnline else {
            syncStatus = isOnline ? .idle : .offline
            return
        }
        
        // 동기화 시작
        performSync()
    }
    
    // 동기화 설정 업데이트
    func updateSyncSettings(autoSync: Bool, interval: String) {
        // 자동 동기화 설정
        UserDefaults.standard.set(autoSync, forKey: "data_sync_auto_enabled")
        
        // 동기화 주기 설정
        switch interval {
        case "매일":
            syncInterval = 24 * 60 * 60
        case "매주":
            syncInterval = 7 * 24 * 60 * 60
        case "매월":
            syncInterval = 30 * 24 * 60 * 60
        case "수동":
            syncInterval = 0
        default:
            syncInterval = 24 * 60 * 60
        }
        
        UserDefaults.standard.set(interval, forKey: "data_sync_interval")
        
        // 기존 예약 취소 후 새로 예약
        if autoSync {
            cancelScheduledSync()
            scheduleSync()
        } else {
            cancelScheduledSync()
        }
    }
    
    // 로그 내보내기
    func exportSyncLogs() -> URL? {
        // 동기화 로그를 파일로 내보내는 기능
        // 실제 구현에서는 로그 수집 및 파일 생성 로직 추가 필요
        return nil
    }
    
    // MARK: - 내부 메서드
    
    // 네트워크 모니터링 설정
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                
                // 온라인 상태로 변경 시 자동 동기화 확인
                if self?.isOnline == true {
                    self?.checkAndTriggerSync()
                } else {
                    self?.syncStatus = .offline
                }
            }
        }
        
        // 모니터링 시작
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }
    
    // 온라인 상태로 변경 시 동기화 확인
    private func checkAndTriggerSync() {
        guard authManager.isLoggedIn else { return }
        
        // 마지막 동기화 시간 확인
        if let lastSync = lastSyncTime,
           syncInterval > 0,
           Date().timeIntervalSince(lastSync) >= syncInterval {
            // 동기화 주기가 지났으면 동기화 시작
            startSync()
        }
    }
    
    // 동기화 스케줄링
    private func scheduleSync() {
        guard syncInterval > 0 else { return }
        
        // 주기적인 동기화 예약
        syncCancellable = Timer.publish(every: syncInterval, on: .main, in: .common)
            .autoconnect()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.startSync()
            }
    }
    
    // 예약된 동기화 취소
    private func cancelScheduledSync() {
        syncCancellable?.cancel()
        syncCancellable = nil
    }
    
    // 실제 동기화 수행
    private func performSync() {
        // 이미 동기화 중이면 무시
        guard syncStatus != .syncing else { return }
        
        // 동기화 상태 업데이트
        syncStatus = .syncing
        syncProgress = 0.0
        
        // 백그라운드 작업 시작 (앱이 백그라운드로 전환되어도 동기화 완료 보장)
        startBackgroundTask()
        
        // 사용자 ID 확인
        guard let userId = getUserId() else {
            syncStatus = .failed
            endBackgroundTask()
            return
        }
        
        // 단계별 동기화 진행
        // 1. 원격 변경사항 확인
        checkRemoteChanges(userId: userId) { [weak self] hasRemoteChanges in
            // 2. 로컬 변경사항 확인
            self?.syncProgress = 0.3
            self?.checkLocalChanges(userId: userId) { hasLocalChanges in
                
                // 3. 변경사항이 있는 경우 동기화 수행
                if hasRemoteChanges || hasLocalChanges {
                    self?.syncProgress = 0.5
                    self?.performDataMerge(userId: userId) { success in
                        DispatchQueue.main.async {
                            if success {
                                self?.syncStatus = .completed
                                self?.lastSyncTime = Date()
                                // 마지막 동기화 시간 저장
                                UserDefaults.standard.set(self?.lastSyncTime, forKey: "data_sync_last_time")
                            } else {
                                self?.syncStatus = .failed
                            }
                            self?.syncProgress = 1.0
                            self?.endBackgroundTask()
                        }
                    }
                } else {
                    // 변경사항이 없는 경우
                    DispatchQueue.main.async {
                        self?.syncStatus = .completed
                        self?.lastSyncTime = Date()
                        // 마지막 동기화 시간 저장
                        UserDefaults.standard.set(self?.lastSyncTime, forKey: "data_sync_last_time")
                        self?.syncProgress = 1.0
                        self?.endBackgroundTask()
                    }
                }
            }
        }
    }
    
    // 사용자 ID 가져오기
    private func getUserId() -> String? {
        // 로그인된 사용자 ID 형식: "provider_userIdentifier"
        guard authManager.isLoggedIn else { return nil }
        
        let provider = authManager.authProvider.rawValue.lowercased()
        let userEmail = authManager.userEmail
        
        // 이메일 주소로 간단한 해시 생성 (실제 구현에서는 더 안전한 방식 사용 필요)
        return "\(provider)_\(userEmail.hashValue)"
    }
    
    // 원격 변경사항 확인
    private func checkRemoteChanges(userId: String, completion: @escaping (Bool) -> Void) {
        // 원격 저장소(Firebase 등)에서 마지막 동기화 이후 변경된 데이터 확인
        // 실제 구현에서는 서버 API 호출 또는 Firebase 리스너 사용
        
        // 테스트용 더미 구현
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            // 랜덤하게 변경사항 있음/없음 반환 (테스트용)
            let hasChanges = Bool.random()
            completion(hasChanges)
        }
    }
    
    // 로컬 변경사항 확인
    private func checkLocalChanges(userId: String, completion: @escaping (Bool) -> Void) {
        // SwiftData에서 마지막 동기화 이후 변경된 데이터 확인
        // 실제 구현에서는 SwiftData 모델 변경 추적 필요
        
        // 테스트용 더미 구현
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            // 랜덤하게 변경사항 있음/없음 반환 (테스트용)
            let hasChanges = Bool.random()
            completion(hasChanges)
        }
    }
    
    // 데이터 병합 수행
    private func performDataMerge(userId: String, completion: @escaping (Bool) -> Void) {
        // 로컬 및 원격 데이터 병합 수행
        // 실제 구현에서는 충돌 해결 및 양방향 동기화 로직 필요
        
        // 테스트용 더미 구현
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // 성공/실패 랜덤 반환 (테스트용)
            let success = true // 실제 구현에서는 실제 성공/실패 여부 반환
            completion(success)
        }
    }
    
    // 백그라운드 작업 시작
    private func startBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    // 백그라운드 작업 종료
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
}

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
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        // 동기화 항목 선택 (옵션)
                        // ... 여기에 선택적 동기화 항목 추가 가능
                        
                        // 로그 내보내기 (개발/디버깅용)
                        Button(action: {
                            if let logUrl = syncManager.exportSyncLogs() {
                                // 로그 파일 공유
                                let activityVC = UIActivityViewController(
                                    activityItems: [logUrl],
                                    applicationActivities: nil
                                )
                                
                                // 활동 뷰 컨트롤러 표시
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootVC = windowScene.windows.first?.rootViewController {
                                    rootVC.present(activityVC, animated: true)
                                }
                            }
                        }) {
                            Label("동기화 로그 내보내기", systemImage: "square.and.arrow.up")
                                .font(.footnote)
                        }
                    }
                    .padding(.top, 16)
                }
            } else {
                // 로그인되지 않은 경우 안내 메시지
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
    }
}
