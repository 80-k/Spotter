// DependencyContainerKey.swift
// DependencyContainer를 환경 변수로 접근할 수 있게 해주는 키
// Created by woo on 4/1/25.

import SwiftUI

/// DependencyContainer를 EnvironmentKey로 구현
struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.shared
}

/// EnvironmentValues 확장을 통해 container 접근자 제공
extension EnvironmentValues {
    var container: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

/// View 확장으로 편리한 접근자 제공
extension View {
    /// 지정된 DependencyContainer를 View의 환경에 주입
    func withDependencyContainer(_ container: DependencyContainer) -> some View {
        environment(\.container, container)
    }
} 