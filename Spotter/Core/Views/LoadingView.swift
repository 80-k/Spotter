// LoadingView.swift
// 앱 전체에서 재사용 가능한 로딩 상태 표시 컴포넌트
// Created by woo on 4/1/25.

import SwiftUI

/// 앱 전체에서 공통으로 사용할 수 있는 로딩 상태 표시 뷰
struct LoadingView: View {
    // MARK: - 프로퍼티
    
    /// 로딩 메시지 (옵셔널)
    let message: String?
    
    /// 로딩 스타일
    let style: Style
    
    /// 배경 표시 여부
    let showBackground: Bool
    
    // MARK: - 초기화
    
    /// 기본 초기화 메서드
    init(message: String? = nil, style: Style = .circular, showBackground: Bool = true) {
        self.message = message
        self.style = style
        self.showBackground = showBackground
    }
    
    // MARK: - 본문
    
    var body: some View {
        ZStack {
            // 배경
            if showBackground {
                Color(.systemBackground)
                    .opacity(0.8)
                    .ignoresSafeArea()
            }
            
            // 로딩 표시
            VStack(spacing: 16) {
                // 로딩 인디케이터
                Group {
                    switch style {
                    case .circular:
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1.5)
                    case .linear:
                        ProgressView()
                            .progressViewStyle(.linear)
                            .frame(width: 200)
                    case .activity:
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
                .padding()
                
                // 메시지 (있을 경우)
                if let message = message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
            )
            .padding(40)
        }
    }
    
    // MARK: - 스타일 정의
    
    /// 로딩 표시 스타일
    enum Style {
        /// 원형 프로그레스 표시
        case circular
        
        /// 선형 프로그레스 표시
        case linear
        
        /// 단순 활동 표시기
        case activity
    }
}

// MARK: - 편의 메서드

extension LoadingView {
    /// 전체 화면 로딩 뷰
    static func fullScreen(message: String? = nil) -> some View {
        LoadingView(message: message, style: .circular, showBackground: true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// 인라인 로딩 표시 (배경 없음)
    static func inline(message: String? = nil) -> some View {
        LoadingView(message: message, style: .activity, showBackground: false)
            .frame(height: 100)
    }
}

// MARK: - 미리보기

#Preview("기본 로딩 뷰") {
    LoadingView(message: "데이터를 불러오는 중...")
}

#Preview("전체화면 로딩") {
    LoadingView.fullScreen(message: "잠시만 기다려주세요...")
}

#Preview("인라인 로딩") {
    VStack {
        Text("위 콘텐츠")
            .padding()
        
        LoadingView.inline(message: "로딩 중...")
        
        Text("아래 콘텐츠")
            .padding()
    }
    .frame(maxWidth: .infinity)
    .background(Color(.systemGroupedBackground))
} 