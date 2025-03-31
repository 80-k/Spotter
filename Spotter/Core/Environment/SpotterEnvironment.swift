// SpotterEnvironment.swift
// 앱 전체 환경 및 서비스 관리
// Created by woo on 4/18/25.

import Foundation
import SwiftUI
import SwiftData

/// 앱 전체에서 사용하는 환경 및 서비스 객체
///
/// SwiftUI 환경에서 EnvironmentObject로 사용되어 앱 전체에서
/// 일관된 의존성을 제공합니다.
final class SpotterEnvironment: ObservableObject {
    // MARK: - 싱글톤 인스턴스
    
    /// 공유 환경 인스턴스
    static let shared = SpotterEnvironment()
    
    // MARK: - 속성
    
    /// 뷰모델 제공자
    @Published var provider: ViewModelProvider
    
    /// 오류 처리 서비스
    @Published var errorService: ErrorHandlingService
    
    /// 기록 활성화 여부
    @Published var loggingEnabled: Bool = true
    
    /// 현재 테마 설정
    @Published var colorScheme: ColorScheme? = nil
    
    // MARK: - 초기화
    
    /// 기본 초기화
    init(
        provider: ViewModelProvider = DependencyContainer.shared,
        errorService: ErrorHandlingService = ErrorHandlingService.shared
    ) {
        self.provider = provider
        self.errorService = errorService
    }
    
    // MARK: - 테스트용 초기화
    
    /// 테스트 환경 생성
    static func testEnvironment(with mockContext: ModelContext) -> SpotterEnvironment {
        let testContainer = DependencyContainer(container: ModelContainer(for: WorkoutTemplate.self))
        return SpotterEnvironment(provider: testContainer)
    }
}

/// ViewBuilder가 포함된 환경 기능 확장
extension SpotterEnvironment {
    /// 환경 오류 표시 뷰 수정자 생성
    @ViewBuilder
    func errorView<Content: View>(
        content: @escaping () -> Content,
        retryAction: (() -> Void)? = nil
    ) -> some View {
        ZStack {
            content()
            
            if let error = errorService.currentError {
                ErrorBannerView(
                    error: error,
                    onDismiss: { errorService.clearCurrentError() },
                    retryAction: retryAction
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: errorService.currentError != nil)
            }
        }
    }
    
    /// 특정 뷰모델 요청 헬퍼
    func viewModel<T: ViewModelDataSource>(of type: T.Type = T.self) -> T {
        return provider.viewModel(of: type)
    }
}

/// SwiftUI에서 환경 객체 접근 확장
extension View {
    /// 공유 환경 추가
    func withSpotterEnvironment() -> some View {
        self.environmentObject(SpotterEnvironment.shared)
    }
    
    /// 테스트용 환경 추가
    func withTestEnvironment(modelContext: ModelContext) -> some View {
        self.environmentObject(SpotterEnvironment.testEnvironment(with: modelContext))
    }
} 