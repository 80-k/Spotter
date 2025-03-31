// EmptyStateView.swift
// 앱 전체에서 재사용되는 공통 빈 상태 뷰 컴포넌트
// Created by woo on 4/1/25.

import SwiftUI

/// 모든 화면에서 공통으로 사용할 수 있는 빈 상태 뷰
/// 데이터가 없거나 오류 상태 등을 표시할 때 사용
struct EmptyStateView: View {
    // MARK: - 프로퍼티
    
    let icon: String
    let title: String
    let message: String?
    let buttonTitle: String?
    let buttonIcon: String?
    let action: (() -> Void)?
    
    // MARK: - 초기화
    
    /// 전체 옵션을 지정한 초기화
    init(
        icon: String,
        title: String,
        message: String? = nil,
        buttonTitle: String? = nil,
        buttonIcon: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonIcon = buttonIcon
        self.action = action
    }
    
    // MARK: - 뷰 본문
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // 아이콘
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            // 제목
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // 메시지 (옵셔널)
            if let message = message {
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // 버튼 (옵셔널)
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    if let buttonIcon = buttonIcon {
                        Label(buttonTitle, systemImage: buttonIcon)
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    } else {
                        Text(buttonTitle)
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.accentColor)
                .padding(.top, 10)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// MARK: - 편의 초기화 메서드

extension EmptyStateView {
    /// 버튼이 없는 간소화된 초기화
    init(icon: String, title: String, message: String) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = nil
        self.buttonIcon = nil
        self.action = nil
    }
    
    /// 일반적인 검색 결과 없음 상태 생성
    static func searchNoResults(searchText: String, action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "검색 결과 없음",
            message: "'\(searchText)'에 대한 검색 결과가 없습니다",
            buttonTitle: action != nil ? "새로 추가하기" : nil,
            buttonIcon: action != nil ? "plus.circle.fill" : nil,
            action: action
        )
    }
    
    /// 일반적인 오류 상태 생성
    static func error(message: String, retryAction: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "exclamationmark.triangle",
            title: "오류 발생",
            message: message,
            buttonTitle: retryAction != nil ? "다시 시도" : nil,
            buttonIcon: retryAction != nil ? "arrow.clockwise" : nil,
            action: retryAction
        )
    }
}

#Preview {
    Group {
        // 버튼 있는 버전
        EmptyStateView(
            icon: "dumbbell.fill",
            title: "운동 기록이 없습니다",
            message: "첫 번째 운동을 시작하여 건강한 습관을 만들어보세요!",
            buttonTitle: "운동 시작하기",
            buttonIcon: "play.fill",
            action: {}
        )
        
        // 버튼 없는 버전
        EmptyStateView(
            icon: "magnifyingglass",
            title: "검색 결과 없음",
            message: "다른 검색어로 다시 시도해보세요."
        )
        
        // Factory 메서드 사용
        EmptyStateView.searchNoResults(searchText: "벤치프레스", action: {})
        
        // 오류 표시
        EmptyStateView.error(message: "서버에 연결할 수 없습니다.", retryAction: {})
    }
} 