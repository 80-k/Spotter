// OperationsIndicatorView.swift
// 백그라운드 작업을 표시하는 공통 인디케이터 뷰
// Created by woo on 4/15/25.

import SwiftUI

/// 진행 중인 작업 개수를 표시하는 인디케이터 뷰
struct OperationsIndicatorView: View {
    // MARK: - 프로퍼티
    
    let count: Int
    var message: String? = nil
    var position: Position = .bottom
    var style: Style = .default
    
    // MARK: - 뷰 본문
    
    var body: some View {
        VStack {
            if position == .top {
                displayContent
                Spacer()
            } else {
                Spacer()
                displayContent
            }
        }
    }
    
    // MARK: - 서브뷰
    
    private var displayContent: some View {
        Text(message ?? "\(count) 작업 처리 중...")
            .font(.caption)
            .foregroundColor(style.textColor)
            .padding(8)
            .background(style.backgroundColor)
            .cornerRadius(8)
            .padding()
    }
    
    // MARK: - 유형 정의
    
    /// 인디케이터 위치
    enum Position {
        case top
        case bottom
    }
    
    /// 인디케이터 스타일
    struct Style {
        let backgroundColor: Color
        let textColor: Color
        
        static let `default` = Style(
            backgroundColor: Color.blue.opacity(0.8),
            textColor: .white
        )
        
        static let success = Style(
            backgroundColor: Color.green.opacity(0.8),
            textColor: .white
        )
        
        static let warning = Style(
            backgroundColor: Color.orange.opacity(0.8),
            textColor: .white
        )
    }
}

// MARK: - 미리보기

#Preview {
    VStack {
        OperationsIndicatorView(count: 3)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .border(Color.gray)
        
        OperationsIndicatorView(
            count: 1,
            message: "데이터 저장 중...",
            position: .top,
            style: .success
        )
        .frame(maxWidth: .infinity, maxHeight: 200)
        .border(Color.gray)
        
        OperationsIndicatorView(
            count: 2,
            message: "네트워크 동기화 중...",
            style: .warning
        )
        .frame(maxWidth: .infinity, maxHeight: 200)
        .border(Color.gray)
    }
    .padding()
} 