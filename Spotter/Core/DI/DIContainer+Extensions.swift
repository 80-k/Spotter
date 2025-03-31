// DIContainer+Extensions.swift
// DIContainer 확장으로 비동기 리포지토리와 서비스 접근 방법 제공
// Created by woo on 4/1/25.

import Foundation
import SwiftData

// MARK: - Repository 접근
extension DIContainer {
    // 템플릿 리포지토리
    func templateRepository() -> TemplateRepository? {
        guard let modelContext = modelContext else { return nil }
        return TemplateRepository(modelContext: modelContext)
    }
    
    // 세션 리포지토리
    func sessionRepository() -> SessionRepository? {
        guard let modelContext = modelContext else { return nil }
        return SessionRepository(modelContext: modelContext)
    }
    
    // 운동 아이템 리포지토리
    func exerciseRepository() -> ExerciseRepository? {
        guard let modelContext = modelContext else { return nil }
        return ExerciseRepository(modelContext: modelContext)
    }
}

// MARK: - Actor 서비스
extension DIContainer {
    // 템플릿 데이터 액터 생성
    func makeTemplateDataActor() -> TemplateDataActor? {
        guard let repo = templateRepository() else { return nil }
        return TemplateDataActor(repository: repo)
    }
}

// MARK: - ViewModel 팩토리
extension DIContainer {
    // 비동기 템플릿 목록 ViewModel 생성 (일반)
    func makeAsyncTemplateListViewModel() -> AsyncTemplateListViewModel? {
        guard let templateRepo = templateRepository(),
              let sessionRepo = sessionRepository() else { return nil }
        
        return AsyncTemplateListViewModel(
            repository: templateRepo,
            sessionRepository: sessionRepo
        )
    }
    
    // Actor 기반 템플릿 ViewModel 생성
    func makeActorTemplateViewModel() -> ActorTemplateViewModel? {
        guard let templateRepo = templateRepository(),
              let sessionRepo = sessionRepository() else { return nil }
        
        return ActorTemplateViewModel(
            repository: templateRepo,
            sessionRepository: sessionRepo
        )
    }
}

// MARK: - 서비스 접근
extension DIContainer {
    // 다른 서비스들을 필요에 따라 여기에 추가
    
    // 예: 백업 서비스
    func backupService() -> BackupService? {
        // 아직 구현되지 않음
        return nil
    }
}

// MARK: - 유틸리티 서비스
extension DIContainer {
    // 알림 서비스
    func notificationService() -> NotificationService? {
        return NotificationService()
    }
    
    // 에러 로깅 서비스
    func errorLogService() -> ErrorLogService {
        return ErrorLogService.shared
    }
}

// MARK: - 알림 서비스 구현
class NotificationService {
    // 알림 관련 설정 및 처리 로직
    func requestPermission() {
        // 알림 권한 요청
    }
    
    func scheduleWorkoutReminder(at date: Date, title: String) {
        // 운동 알림 스케줄링
    }
}

// MARK: - 백업 서비스 인터페이스
protocol BackupService {
    func backupData() async throws
    func restoreData() async throws
    var lastBackupDate: Date? { get }
}

// MARK: - 에러 로깅 서비스
final class ErrorLogService {
    static let shared = ErrorLogService()
    
    private init() {}
    
    // 최근 로그 저장
    private var recentLogs: [String] = []
    private let maxLogCount = 50
    
    // 오류 로깅
    func logError(_ error: Error, file: String = #file, line: Int = #line, function: String = #function) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function) - \(error.localizedDescription)"
        
        // 로그 추가
        recentLogs.append(logMessage)
        
        // 최대 개수 유지
        if recentLogs.count > maxLogCount {
            recentLogs.removeFirst()
        }
        
        // 디버그 콘솔에 출력
        print("ERROR: \(logMessage)")
        
        // 앱 에러가 있으면 추가 정보 출력
        if let appError = error as? AppError {
            print("DEBUG: \(appError.debugDescription)")
        }
    }
    
    // 로그 반환
    func getRecentLogs() -> [String] {
        return recentLogs
    }
    
    // 로그 초기화
    func clearLogs() {
        recentLogs.removeAll()
    }
} 