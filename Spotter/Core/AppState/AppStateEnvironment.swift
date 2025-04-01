// AppStateEnvironment.swift
// 앱 상태 서비스를 위한 환경 값 확장
//  Created by woo on 3/31/25.

import Foundation
import SwiftUI

// 환경 값 키 정의
private struct AppStateServiceKey: EnvironmentKey {
    static let defaultValue: AppStateServiceProtocol = AppStateService.shared
}

// 환경 값 확장
extension EnvironmentValues {
    var appState: AppStateServiceProtocol {
        get { self[AppStateServiceKey.self] }
        set { self[AppStateServiceKey.self] = newValue }
    }
} 