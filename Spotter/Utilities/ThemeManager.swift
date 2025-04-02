// ThemeManager.swift
// 앱 테마(다크모드/라이트모드) 관리
// Created by woo on 3/30/25.
// 참고: 이 파일은 더 이상 사용되지 않으며 ThemeService.swift로 대체되었습니다.
// 호환성을 위해 유지되고 있으나 새로운 기능은 ThemeService를 사용해야 합니다.

import SwiftUI

/*
// 앱 테마 열거형
enum AppTheme: Int, CaseIterable {
    case system   // 시스템 설정 따름
    case light    // 항상 라이트 모드
    case dark     // 항상 다크 모드
    
    // 테마 이름
    var name: String {
        switch self {
        case .system:
            return "시스템"
        case .light:
            return "라이트"
        case .dark:
            return "다크"
        }
    }
    
    // 테마 아이콘
    var icon: String {
        switch self {
        case .system:
            return "gearshape.fill"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
    
    // 컬러 스킴 반환
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil  // nil은 시스템 설정을 따름
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

// 테마 관리 클래스
class ThemeManager: ObservableObject {
    // 싱글톤 인스턴스
    static let shared = ThemeManager()
    
    // 현재 테마 (UserDefaults에 저장)
    @Published var currentTheme: AppTheme {
        didSet {
            // 테마 변경 시 UserDefaults에 저장
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "app_theme")
        }
    }
    
    // 초기화
    private init() {
        // UserDefaults에서 저장된 테마 가져오기
        if let savedThemeRawValue = UserDefaults.standard.object(forKey: "app_theme") as? Int,
           let savedTheme = AppTheme(rawValue: savedThemeRawValue) {
            currentTheme = savedTheme
        } else {
            // 기본값은 시스템 설정 따름
            currentTheme = .system
        }
    }
    
    // 테마 변경 메서드
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    // 다음 테마로 순환 (시스템 -> 라이트 -> 다크 -> 시스템)
    func cycleTheme() {
        let allThemes = AppTheme.allCases
        let currentIndex = allThemes.firstIndex(of: currentTheme) ?? 0
        let nextIndex = (currentIndex + 1) % allThemes.count
        currentTheme = allThemes[nextIndex]
    }
}

// SwiftUI에서 사용할 수 있는 환경 키
struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

// 환경 값 확장
extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
*/
