// StyleModifiers.swift
// 앱 전체에서 재사용할 수 있는 스타일 모디파이어 모음
// Created by woo on 4/1/25.

import SwiftUI

// MARK: - 버튼 스타일

/// 주요 액션 버튼 스타일 (파란색 배경)
struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: 250)
            .background(Color.blue)
            .cornerRadius(10)
    }
}

/// 보조 액션 버튼 스타일 (테두리만 있는 버튼)
struct SecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.blue)
            .padding()
            .frame(maxWidth: 250)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
            )
    }
}

// MARK: - 카드 스타일

/// 카드 형태의 컨테이너 스타일
struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 텍스트 스타일

/// 섹션 제목 스타일
struct SectionTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
    }
}

/// 설명 텍스트 스타일
struct DescriptionTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
}

// MARK: - View 확장

extension View {
    /// 주요 액션 버튼 스타일 적용
    func primaryButtonStyle() -> some View {
        modifier(PrimaryButtonStyle())
    }
    
    /// 보조 액션 버튼 스타일 적용
    func secondaryButtonStyle() -> some View {
        modifier(SecondaryButtonStyle())
    }
    
    /// 카드 스타일 적용
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }
    
    /// 섹션 제목 스타일 적용
    func sectionTitleStyle() -> some View {
        modifier(SectionTitleStyle())
    }
    
    /// 설명 텍스트 스타일 적용
    func descriptionTextStyle() -> some View {
        modifier(DescriptionTextStyle())
    }
} 