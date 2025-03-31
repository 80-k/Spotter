// AppError.swift
// 앱 전체에서 사용하는 공통 에러 타입 정의
// Created by woo on 4/1/25.

import Foundation

/// 앱 전체에서 사용하는 공통 에러 타입
enum AppError: Error, Equatable {
    // 데이터 관련 오류
    case dataNotFound
    case invalidData
    case persistenceError(String)
    
    // 네트워크 관련 오류
    case networkError(String)
    case serverError(Int)
    case connectionError
    
    // 인증 관련 오류
    case authenticationError
    case unauthorized
    
    // 사용자 입력 관련 오류
    case invalidInput(String)
    case validationError(String)
    
    // 기타 오류
    case unknownError
    case customError(String)
    
    // 사용자에게 표시할 메시지
    var userMessage: String {
        switch self {
        case .dataNotFound:
            return "요청한 데이터를 찾을 수 없습니다."
        case .invalidData:
            return "데이터 형식이 올바르지 않습니다."
        case .persistenceError(let message):
            return "데이터 저장 오류: \(message)"
            
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .serverError(let code):
            return "서버 오류 (코드: \(code))"
        case .connectionError:
            return "인터넷 연결을 확인해주세요."
            
        case .authenticationError:
            return "인증에 실패했습니다. 다시 로그인해주세요."
        case .unauthorized:
            return "접근 권한이 없습니다."
            
        case .invalidInput(let field):
            return "\(field) 입력이 올바르지 않습니다."
        case .validationError(let message):
            return "유효성 검사 오류: \(message)"
            
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        case .customError(let message):
            return message
        }
    }
    
    // 개발자를 위한 디버그 메시지
    var debugDescription: String {
        switch self {
        case .dataNotFound:
            return "DataNotFound: Entity not found in the data store"
        case .invalidData:
            return "InvalidData: Data format is incorrect or corrupted"
        case .persistenceError(let message):
            return "PersistenceError: \(message)"
            
        case .networkError(let message):
            return "NetworkError: \(message)"
        case .serverError(let code):
            return "ServerError: HTTP \(code)"
        case .connectionError:
            return "ConnectionError: No internet connection"
            
        case .authenticationError:
            return "AuthenticationError: Failed to authenticate user"
        case .unauthorized:
            return "Unauthorized: User does not have required permissions"
            
        case .invalidInput(let field):
            return "InvalidInput: \(field) validation failed"
        case .validationError(let message):
            return "ValidationError: \(message)"
            
        case .unknownError:
            return "UnknownError: Unexpected error occurred"
        case .customError(let message):
            return "CustomError: \(message)"
        }
    }
}

// MARK: - Result 타입 확장 (에러 처리 도우미)
extension Result where Failure == AppError {
    /// 성공 케이스에 대한 값 또는 기본값 반환
    func valueOrDefault(_ defaultValue: Success) -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return defaultValue
        }
    }
    
    /// 값이 있다면 반환하고, 없다면 dataNotFound 오류 생성
    static func valueOrNotFound(_ value: Success?) -> Result<Success, AppError> {
        if let value = value {
            return .success(value)
        } else {
            return .failure(.dataNotFound)
        }
    }
}

// MARK: - 디버깅을 위한 확장
extension AppError: CustomDebugStringConvertible {
    var localizedDescription: String {
        return userMessage
    }
} 