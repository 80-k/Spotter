//
//  ThemeColor.swift
//  Spotter
//
//  Created by woo on 4/2/25.
//

import SwiftUI

// 다크 모드 대응을 위한 공통 색상 유틸리티
enum ThemeColor {
    // 배경색 - 다크 모드 대응
    static func backgroundColor(colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.systemBackground)
        default:
            return Color.gray.opacity(0.03)
        }
    }
    
    // 카드 배경색 - 다크 모드 대응
    static func cardBackgroundColor(colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.secondarySystemBackground)
        default:
            return Color.white
        }
    }
    
    // 그림자 색상 - 다크 모드 대응
    static func shadowColor(colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color.black.opacity(0.1)
        default:
            return Color.black.opacity(0.03)
        }
    }
} 