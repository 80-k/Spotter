// LoggerService.swift
// 중앙화된 로깅 서비스
// Created by woo on 4/1/25.

import Foundation
import os

/// 로그 수준을 정의하는 열거형
enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    
    // 비교 연산자 구현
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    // 표시 이름
    var displayName: String {
        switch self {
        case .debug: return "디버그"
        case .info: return "정보"
        case .warning: return "경고"
        case .error: return "오류"
        }
    }
    
    // 로그 이모지
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

/// 애플리케이션 전체의 로깅을 담당하는 중앙화된 로깅 서비스
final class LoggerService {
    // 싱글톤 인스턴스
    static let shared = LoggerService()
    
    // 기본 로그 레벨
    private var minimumLogLevel: LogLevel = .debug
    
    // OS 로거 카테고리 매핑
    private var loggers: [String: Logger] = [:]
    
    // 기본 서브시스템
    private let defaultSubsystem = "com.spotter.app"
    
    // 싱글톤 초기화
    private init() {}
    
    /// 로그 레벨 설정
    func setMinimumLogLevel(_ level: LogLevel) {
        minimumLogLevel = level
    }
    
    /// OS 로거 반환 (카테고리별로 캐싱됨)
    private func getLogger(for category: String) -> Logger {
        if let logger = loggers[category] {
            return logger
        }
        
        let logger = Logger(subsystem: defaultSubsystem, category: category)
        loggers[category] = logger
        return logger
    }
    
    // MARK: - 로깅 메서드
    
    /// 디버그 레벨 로그
    func debug(_ message: String, category: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard minimumLogLevel <= .debug else { return }
        
        let logger = getLogger(for: category)
        let formattedMessage = formatMessage(message, level: .debug, file: file, function: function, line: line)
        logger.debug("\(formattedMessage, privacy: .public)")
    }
    
    /// 정보 레벨 로그
    func info(_ message: String, category: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard minimumLogLevel <= .info else { return }
        
        let logger = getLogger(for: category)
        let formattedMessage = formatMessage(message, level: .info, file: file, function: function, line: line)
        logger.info("\(formattedMessage, privacy: .public)")
    }
    
    /// 경고 레벨 로그
    func warning(_ message: String, category: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard minimumLogLevel <= .warning else { return }
        
        let logger = getLogger(for: category)
        let formattedMessage = formatMessage(message, level: .warning, file: file, function: function, line: line)
        logger.warning("\(formattedMessage, privacy: .public)")
    }
    
    /// 오류 레벨 로그
    func error(_ message: String, category: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard minimumLogLevel <= .error else { return }
        
        let logger = getLogger(for: category)
        let formattedMessage = formatMessage(message, level: .error, file: file, function: function, line: line)
        logger.error("\(formattedMessage, privacy: .public)")
    }
    
    /// 메시지 포맷팅
    private func formatMessage(_ message: String, level: LogLevel, file: String, function: String, line: Int) -> String {
        let filename = URL(fileURLWithPath: file).lastPathComponent
        return "\(level.emoji) [\(filename):\(line)] \(message)"
    }
}

// MARK: - 간편한 전역 접근자
/// 로거 서비스에 쉽게 접근하기 위한 전역 함수
func spotterLog(
    _ message: String,
    level: LogLevel = .debug,
    category: String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    let logger = LoggerService.shared
    
    switch level {
    case .debug:
        logger.debug(message, category: category, file: file, function: function, line: line)
    case .info:
        logger.info(message, category: category, file: file, function: function, line: line)
    case .warning:
        logger.warning(message, category: category, file: file, function: function, line: line)
    case .error:
        logger.error(message, category: category, file: file, function: function, line: line)
    }
} 