// NavigationHelper.swift
// 앱 전체에서 사용되는 네비게이션 관련 유틸리티
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

// MARK: - 네비게이션 상태 관리

/// 네비게이션 상태를 관리하는 클래스
/// 여러 화면에서 일관된 네비게이션 처리를 가능하게 함
class NavigationStateManager: ObservableObject {
    // 싱글톤 인스턴스
    static let shared = NavigationStateManager()
    
    // 템플릿 관련 네비게이션 상태
    @Published var selectedTemplateId: PersistentIdentifier? = nil
    @Published var isAddingNewTemplate: Bool = false
    
    // 운동 관련 네비게이션 상태
    @Published var selectedExerciseId: PersistentIdentifier? = nil
    @Published var isAddingNewExercise: Bool = false
    
    // 활성 운동 관련 상태
    @Published var activeSessionId: PersistentIdentifier? = nil
    
    private init() {}
    
    // 모든 선택 상태 초기화
    func resetAllSelections() {
        selectedTemplateId = nil
        selectedExerciseId = nil
        isAddingNewTemplate = false
        isAddingNewExercise = false
    }
}

// MARK: - 네비게이션 링크 래퍼

/// 네비게이션 링크를 래핑하여 더 선언적인 방식으로 사용할 수 있게 해주는 뷰
struct AppNavigationLink<Label: View, Destination: View>: View {
    let isActive: Binding<Bool>
    let destination: () -> Destination
    let label: () -> Label
    
    init(isActive: Binding<Bool>, @ViewBuilder destination: @escaping () -> Destination, @ViewBuilder label: @escaping () -> Label) {
        self.isActive = isActive
        self.destination = destination
        self.label = label
    }
    
    var body: some View {
        // iOS 16+ 스타일로 업데이트
        if #available(iOS 16.0, *) {
            label()
                .navigationDestination(isPresented: isActive) {
                    destination()
                }
        } else {
            // 이전 iOS 버전 호환성을 위한 폴백
            NavigationLink(
                isActive: isActive,
                destination: { destination() },
                label: { label() }
            )
        }
    }
}

// MARK: - NavigationPath 유틸리티

/// 앱에서 사용되는 네비게이션 경로 타입
enum AppNavigationPath: Hashable {
    case templateDetail(id: PersistentIdentifier)
    case exerciseDetail(id: PersistentIdentifier)
    case exerciseSelection
    case addExercise
    case activeWorkout(id: PersistentIdentifier)
}

/// NavigationPath 확장 - 더 쉬운 사용을 위한 유틸리티 메서드
extension NavigationPath {
    mutating func navigateToTemplate(id: PersistentIdentifier) {
        self.append(AppNavigationPath.templateDetail(id: id))
    }
    
    mutating func navigateToExercise(id: PersistentIdentifier) {
        self.append(AppNavigationPath.exerciseDetail(id: id))
    }
    
    mutating func navigateToExerciseSelection() {
        self.append(AppNavigationPath.exerciseSelection)
    }
    
    mutating func navigateToAddExercise() {
        self.append(AppNavigationPath.addExercise)
    }
    
    mutating func navigateToActiveWorkout(id: PersistentIdentifier) {
        self.append(AppNavigationPath.activeWorkout(id: id))
    }
}

// MARK: - View 확장

extension View {
    /// 네비게이션 바 배경 및 스타일 적용
    func withDefaultNavigationStyle() -> some View {
        self.toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Material.regular, for: .navigationBar)
    }
}
