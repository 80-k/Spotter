// ThemeService.swift
// 테마 서비스 구현
//  Created by woo on 3/31/25.

import Foundation
import SwiftUI

/// 테마 관리 서비스
final class ThemeService: ObservableObject, ThemeServiceProtocol {
    // 싱글톤 인스턴스
    static let shared = ThemeService()
    
    // 테마 변경 시 UI 업데이트를 위한 퍼블리셔
    @Published private(set) var currentTheme: ThemeType
    
    /// 모든 테마 옵션
    let allThemes: [ThemeType] = ThemeType.allCases
    
    // 저장소 키
    private let themeStorageKey = "user_theme_preference"
    
    // 초기화
    private init() {
        // 저장된 테마 설정 불러오기
        if let savedTheme = UserDefaults.standard.string(forKey: themeStorageKey),
           let theme = ThemeType(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            // 기본값은 시스템 테마
            self.currentTheme = .system
        }
    }
    
    /// 테마 변경
    func setTheme(_ theme: ThemeType) {
        // 현재 테마 업데이트
        currentTheme = theme
        
        // 사용자 기본 설정에 테마 저장
        UserDefaults.standard.set(theme.rawValue, forKey: themeStorageKey)
    }
} 