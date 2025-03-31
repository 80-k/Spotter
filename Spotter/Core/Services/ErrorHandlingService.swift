// ErrorHandlingService.swift
// 중앙화된 오류 처리 서비스
// Created by woo on 4/18/25.

import Foundation
import SwiftUI

/// 애플리케이션 전반의 오류를 처리하는 서비스
///
/// 이 서비스는 다양한 오류 유형을 일관된 방식으로 처리하고,
/// 오류 로깅, 분석 및 사용자 피드백을 제공합니다.
final class ErrorHandlingService: ObservableObject {
    // MARK: - 싱글톤 인스턴스
    
    /// 공유 인스턴스
    static let shared = ErrorHandlingService()
    
    // MARK: - 속성
    
    /// 최근 발생한 오류 (일반 화면에서 표시용)
    @Published var currentError: AppError?
    
    /// 오류 발생 시 로그 수준 설정
    enum LogLevel: Int {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
        case critical = 4
    }
    
    /// 현재 로그 레벨 (이 레벨 이상만 로깅)
    var logLevel: LogLevel = .debug
    
    // MARK: - 오류 처리 메서드
    
    /// 오류 처리 및 변환
    /// - Parameters:
    ///   - error: 처리할 오류
    ///   - viewModel: 오류를 표시할 뷰모델 (옵션)
    ///   - level: 오류 로깅 수준
    ///   - file: 오류 발생 파일 (자동 제공)
    ///   - line: 오류 발생 줄 (자동 제공)
    func handle(
        _ error: Error,
        in viewModel: ViewModelDataSource? = nil,
        level: LogLevel = .warning,
        file: String = #file,
        line: Int = #line
    ) {
        // 앱 오류로 변환
        let appError = convertToAppError(error)
        
        // 뷰모델에 설정 (제공된 경우)
        if let viewModel = viewModel {
            Task { @MainActor in
                viewModel.error = appError
            }
        }
        
        // 현재 오류 업데이트
        Task { @MainActor in
            self.currentError = appError
        }
        
        // 로깅
        logError(appError, level: level, file: file, line: line)
        
        // 여기에 추가 처리 가능:
        // - 분석 서비스에 오류 보고
        // - 오류 발생 카운팅 및 통계
        // - 여러 번 반복 발생 시 특별 처리
    }
    
    /// 현재 오류 초기화
    func clearCurrentError() {
        Task { @MainActor in
            currentError = nil
        }
    }
    
    // MARK: - 내부 유틸리티 메서드
    
    /// 일반 오류를 앱 오류로 변환
    private func convertToAppError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        // 네트워크 오류 처리
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkError("네트워크 연결이 끊어졌습니다.")
            case .timedOut:
                return .networkError("네트워크 요청 시간이 초과되었습니다.")
            case .cannotFindHost, .cannotConnectToHost:
                return .networkError("서버에 연결할 수 없습니다.")
            default:
                return .networkError(urlError.localizedDescription)
            }
        }
        
        // SwiftData 오류 처리
        if error is any LocalizedError, error.localizedDescription.contains("database") {
            return .dataError("데이터베이스 오류가 발생했습니다: \(error.localizedDescription)")
        }
        
        // 기타 오류는 일반 오류로 처리
        return .customError(error.localizedDescription)
    }
    
    /// 오류 로깅
    private func logError(_ error: AppError, level: LogLevel, file: String, line: Int) {
        // 설정된 로그 레벨 이상만 출력
        guard level.rawValue >= logLevel.rawValue else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let levelString: String
        
        switch level {
        case .debug: levelString = "📘 디버그"
        case .info: levelString = "📗 정보"
        case .warning: levelString = "📙 경고"
        case .error: levelString = "📕 오류"
        case .critical: levelString = "🚨 심각"
        }
        
        print("\(levelString) [\(fileName):\(line)] - \(error.localizedDescription)")
    }
} 