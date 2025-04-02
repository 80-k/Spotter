// DataSyncManager.swift
// 데이터 동기화 관리 - 핵심 로직
// Created by woo on 3/30/25.

import Foundation
import SwiftData
import Combine
import SwiftUI

// 데이터 동기화 관리 클래스
class DataSyncManager: ObservableObject {
    // 싱글톤 인스턴스
    static let shared = DataSyncManager()
    
    // 현재 동기화 상태
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncTime: Date?
    @Published var syncProgress: Double = 0.0
    
    // 네트워크 상태
    @Published var isOnline: Bool = true
    
    // 인증 관리자
    private let authManager = AuthManager.shared
    
    // 동기화 주기 설정 (기본값: 하루)
    private var syncInterval: TimeInterval = 24 * 60 * 60
    
    // 동기화 작업 취소용 토큰
    private var syncCancellable: AnyCancellable?
    
    // 백그라운드 작업 관리용 취소 토큰
    private var backgroundTaskCancellable: AnyCancellable?
    
    private init() {
        // 네트워크 상태 모니터링은 appState의 scenePhase 변화로 대체
        setupNetworkCheck()
        
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
        
        // 임시 파일 경로 생성
        let tempDir = FileManager.default.temporaryDirectory
        let logFile = tempDir.appendingPathComponent("sync_logs_\(Date().timeIntervalSince1970).txt")
        
        // 샘플 로그 내용 (실제 구현시 확장)
        let logContent = """
        Sync Logs - Generated \(Date())
        
        Last sync: \(lastSyncTime?.description ?? "Never")
        Current status: \(syncStatus)
        Network status: \(isOnline ? "Online" : "Offline")
        
        --- Detailed Logs ---
        (No detailed logs available in this version)
        """
        
        do {
            try logContent.write(to: logFile, atomically: true, encoding: .utf8)
            return logFile
        } catch {
            print("로그 파일 생성 실패: \(error)")
            return nil
        }
    }
    
    // MARK: - 내부 메서드
    
    // 네트워크 상태 확인 - SwiftUI 방식으로 대체
    private func setupNetworkCheck() {
        // TODO: 실제 구현 시 적절한 네트워크 연결 확인 로직 추가
        // 현재는 단순화를 위해 항상 온라인으로 가정
        isOnline = true
    }
    
    // 온라인 상태로 변경 시 동기화 확인
    func checkAndTriggerSync() {
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
        
        // 백그라운드 작업 관리용 타이머 설정 (25초 후 자동 종료)
        backgroundTaskCancellable = Timer.publish(every: 25, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink { [weak self] _ in
                // 시간이 너무 오래 걸리면 강제 종료
                self?.syncStatus = .failed
                self?.syncProgress = 0.0
                print("동기화 시간 초과")
            }
        
        // 사용자 ID 확인
        guard let userId = getUserId() else {
            syncStatus = .failed
            backgroundTaskCancellable?.cancel()
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
                            self?.backgroundTaskCancellable?.cancel()
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
                        self?.backgroundTaskCancellable?.cancel()
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
        
        // 이메일 주소로 간단한 해시 생성
        return "\(provider)_\(userEmail.hashValue)"
    }
    
    // 원격 변경사항 확인
    private func checkRemoteChanges(userId: String, completion: @escaping (Bool) -> Void) {
        // TODO: 원격 저장소(Firebase 등)에서 마지막 동기화 이후 변경된 데이터 확인
        // 현재는 테스트용 더미 구현
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let hasChanges = Bool.random()
            completion(hasChanges)
        }
    }
    
    // 로컬 변경사항 확인
    private func checkLocalChanges(userId: String, completion: @escaping (Bool) -> Void) {
        // TODO: SwiftData에서 마지막 동기화 이후 변경된 데이터 확인
        // 현재는 테스트용 더미 구현
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let hasChanges = Bool.random()
            completion(hasChanges)
        }
    }
    
    // 데이터 병합 수행
    private func performDataMerge(userId: String, completion: @escaping (Bool) -> Void) {
        // TODO: 로컬 및 원격 데이터 병합 수행
        // 현재는 테스트용 더미 구현
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let success = true
            completion(success)
        }
    }
}
