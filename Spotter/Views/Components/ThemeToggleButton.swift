// ThemeToggleButton.swift
// 테마 전환 버튼 컴포넌트
// Created by woo on 3/30/25.

import SwiftUI

struct ThemeToggleButton: View {
    // Environment에서 ThemeService 가져오기
    @Environment(\.themeService) private var themeService
    
    // 버튼 크기
    var size: CGFloat = 24
    var showText: Bool = true
    
    var body: some View {
        Button(action: {
            // 다음 테마로 순환
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                cycleTheme()
            }
        }) {
            HStack(spacing: 8) {
                // 현재 테마 아이콘
                Image(systemName: themeService.currentTheme.iconName)
                    .font(.system(size: size))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(iconColor)
                
                // 테마 이름 (옵션)
                if showText {
                    Text(themeService.currentTheme.rawValue)
                        .font(.footnote)
                        .bold()
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
            )
        }
    }
    
    // 테마 순환 메서드
    private func cycleTheme() {
        let themes = ThemeType.allCases
        let currentIndex = themes.firstIndex(of: themeService.currentTheme) ?? 0
        let nextIndex = (currentIndex + 1) % themes.count
        themeService.setTheme(themes[nextIndex])
    }
    
    // 아이콘 색상
    private var iconColor: Color {
        switch themeService.currentTheme {
        case .system:
            return .blue
        case .light:
            return .orange
        case .dark:
            return .indigo
        }
    }
    
    // 배경 색상
    private var backgroundColor: Color {
        switch themeService.currentTheme {
        case .system:
            return .blue.opacity(0.1)
        case .light:
            return .orange.opacity(0.1)
        case .dark:
            return .indigo.opacity(0.1)
        }
    }
}

// 소형 토글 버튼 (아이콘만)
struct CompactThemeToggleButton: View {
    var body: some View {
        ThemeToggleButton(showText: false)
    }
}

// 미리보기
#Preview {
    VStack(spacing: 20) {
        ThemeToggleButton()
        CompactThemeToggleButton()
    }
    .padding()
}
