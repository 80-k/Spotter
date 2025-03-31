// ErrorView.swift
// 앱 전체에서 재사용 가능한 오류 표시 컴포넌트
// Created by woo on 4/1/25.

import SwiftUI

/// 앱 전체에서 공통으로 사용할 수 있는 오류 표시 뷰
struct ErrorView: View {
    // MARK: - 프로퍼티
    
    /// 오류 제목
    let title: String
    
    /// 오류 메시지
    let message: String
    
    /// 재시도 버튼 텍스트 (nil이면 버튼 없음)
    let retryButtonTitle: String?
    
    /// 닫기 버튼 텍스트 (nil이면 버튼 없음)
    let dismissButtonTitle: String?
    
    /// 재시도 액션
    let onRetry: (() -> Void)?
    
    /// 닫기 액션
    let onDismiss: (() -> Void)?
    
    /// 아이콘 이름
    let iconName: String
    
    // MARK: - 초기화
    
    /// 기본 초기화 메서드
    init(
        title: String,
        message: String,
        retryButtonTitle: String? = "다시 시도",
        dismissButtonTitle: String? = "닫기",
        iconName: String = "exclamationmark.triangle",
        onRetry: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryButtonTitle = onRetry != nil ? retryButtonTitle : nil
        self.dismissButtonTitle = onDismiss != nil ? dismissButtonTitle : nil
        self.iconName = iconName
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }
    
    // MARK: - 본문
    
    var body: some View {
        VStack(spacing: 20) {
            // 아이콘
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(.red)
                .padding(.bottom, 10)
            
            // 제목
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // 메시지
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            
            // 버튼 영역
            HStack(spacing: 16) {
                // 닫기 버튼
                if let dismissButtonTitle = dismissButtonTitle, let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Text(dismissButtonTitle)
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(.bordered)
                }
                
                // 재시도 버튼
                if let retryButtonTitle = retryButtonTitle, let onRetry = onRetry {
                    Button(action: onRetry) {
                        Text(retryButtonTitle)
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
        .padding(20)
    }
}

// MARK: - 편의 생성자

extension ErrorView {
    /// 네트워크 오류 뷰 생성
    static func network(message: String = "네트워크 연결을 확인해주세요", onRetry: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) -> ErrorView {
        ErrorView(
            title: "네트워크 오류",
            message: message,
            iconName: "wifi.slash",
            onRetry: onRetry,
            onDismiss: onDismiss
        )
    }
    
    /// 데이터 로딩 오류 뷰 생성
    static func dataLoading(message: String = "데이터를 불러오는 중 문제가 발생했습니다", onRetry: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) -> ErrorView {
        ErrorView(
            title: "데이터 오류",
            message: message,
            iconName: "exclamationmark.triangle",
            onRetry: onRetry,
            onDismiss: onDismiss
        )
    }
    
    /// AppError로부터 ErrorView 생성
    static func from(error: AppError, onRetry: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) -> ErrorView {
        // 오류 유형에 따라 다른 아이콘 선택
        let iconName: String
        let title: String
        
        switch error {
        case .networkError, .connectionError, .serverError:
            iconName = "wifi.slash"
            title = "네트워크 오류"
        case .dataNotFound, .invalidData, .persistenceError:
            iconName = "database.fill"
            title = "데이터 오류"
        case .authenticationError, .unauthorized:
            iconName = "lock.fill"
            title = "인증 오류"
        case .invalidInput, .validationError:
            iconName = "exclamationmark.triangle"
            title = "입력 오류"
        default:
            iconName = "exclamationmark.circle"
            title = "오류 발생"
        }
        
        return ErrorView(
            title: title,
            message: error.userMessage,
            iconName: iconName,
            onRetry: onRetry,
            onDismiss: onDismiss
        )
    }
}

// MARK: - 미리보기

#Preview("기본 오류 뷰") {
    ErrorView(
        title: "오류 발생",
        message: "예상치 못한 오류가 발생했습니다. 다시 시도해주세요.",
        onRetry: {},
        onDismiss: {}
    )
}

#Preview("네트워크 오류") {
    ErrorView.network(onRetry: {}, onDismiss: {})
}

#Preview("AppError 변환") {
    let appError = AppError.networkError("서버에 연결할 수 없습니다")
    return ErrorView.from(error: appError, onRetry: {}, onDismiss: {})
} 