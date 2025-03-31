// ErrorBannerView.swift
// 화면 하단에 표시되는 오류 배너 컴포넌트
// Created by woo on 4/1/25.

import SwiftUI

/// 화면 하단에 간단한 오류 메시지를 표시하는 컴포넌트
struct ErrorBannerView: View {
    // MARK: - 프로퍼티
    
    /// 표시할
    /// 오류 객체
    let error: AppError
    
    /// 닫기 액션
    let onDismiss: () -> Void
    
    /// 배경색 (기본값: 빨간색)
    var backgroundColor: Color = .red
    
    /// 제한 시간 후 자동 닫기 (초 단위, nil이면 자동 닫기 없음)
    var autoDismissAfter: Double? = nil
    
    // MARK: - 상태
    
    @State private var isVisible: Bool = false
    
    // MARK: - 초기화
    
    init(error: AppError, backgroundColor: Color = .red, autoDismissAfter: Double? = nil, onDismiss: @escaping () -> Void) {
        self.error = error
        self.backgroundColor = backgroundColor
        self.autoDismissAfter = autoDismissAfter
        self.onDismiss = onDismiss
    }
    
    // MARK: - 뷰 본문
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Text(error.userMessage)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding()
                    .background(backgroundColor.opacity(0.9))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                
                Spacer()
                
                Button {
                    withAnimation {
                        isVisible = false
                        onDismiss()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
                .padding(.trailing, 24)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onAppear {
            withAnimation(.easeInOut) {
                isVisible = true
            }
            
            // 자동 닫기 설정이 있으면 타이머 시작
            if let dismissTime = autoDismissAfter {
                DispatchQueue.main.asyncAfter(deadline: .now() + dismissTime) {
                    if isVisible {
                        withAnimation {
                            isVisible = false
                            onDismiss()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 팩토리 메서드

extension ErrorBannerView {
    /// 빠른 오류 배너 생성 (기본 스타일)
    static func standard(_ message: String, onDismiss: @escaping () -> Void) -> ErrorBannerView {
        ErrorBannerView(
            error: AppError.customError(message),
            autoDismissAfter: 5.0,
            onDismiss: onDismiss
        )
    }
    
    /// 네트워크 오류 배너 (파란색)
    static func network(_ error: AppError, onDismiss: @escaping () -> Void) -> ErrorBannerView {
        ErrorBannerView(
            error: error,
            backgroundColor: .blue,
            onDismiss: onDismiss
        )
    }
    
    /// 경고 배너 (주황색, 자동 닫힘)
    static func warning(_ message: String, onDismiss: @escaping () -> Void) -> ErrorBannerView {
        ErrorBannerView(
            error: AppError.customError(message),
            backgroundColor: .orange,
            autoDismissAfter: 4.0,
            onDismiss: onDismiss
        )
    }
}

// MARK: - 미리보기

#Preview("기본 오류 배너") {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        ErrorBannerView(
            error: AppError.customError("예상치 못한 오류가 발생했습니다."),
            onDismiss: {}
        )
    }
}

#Preview("네트워크 오류") {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        VStack {
            Text("화면 콘텐츠")
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding()
            
            Spacer()
        }
        
        ErrorBannerView.network(
            AppError.networkError("인터넷 연결을 확인해주세요"),
            onDismiss: {}
        )
    }
}

#Preview("경고 배너") {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        ErrorBannerView.warning(
            "저장되지 않은 변경 사항이 있습니다.",
            onDismiss: {}
        )
    }
} 