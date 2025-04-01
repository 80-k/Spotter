// ThemeEnvironment.swift
// 테마 서비스를 위한 환경 값 확장
//  Created by woo on 3/31/25.

import Foundation
import SwiftUI

// 환경 값 키 정의
private struct ThemeServiceKey: EnvironmentKey {
    static let defaultValue: ThemeServiceProtocol = ThemeService.shared
}

// 환경 값 확장
extension EnvironmentValues {
    var themeService: ThemeServiceProtocol {
        get { self[ThemeServiceKey.self] }
        set { self[ThemeServiceKey.self] = newValue }
    }
} 