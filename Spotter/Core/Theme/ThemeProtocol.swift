// ThemeProtocol.swift
// 테마 서비스 프로토콜
//  Created by woo on 3/31/25.

import Foundation
import SwiftUI

/// 테마 유형
enum ThemeType: String, CaseIterable {
    case system = "시스템"
    case light = "라이트"
    case dark = "다크"
    
    /// 색상 스키마
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    /// 아이콘 이름
    var iconName: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

/// 테마 서비스 프로토콜
protocol ThemeServiceProtocol: AnyObject {
    /// 현재 테마
    var currentTheme: ThemeType { get }
    
    /// 모든 테마 옵션
    var allThemes: [ThemeType] { get }
    
    /// 테마 변경
    func setTheme(_ theme: ThemeType)
} 