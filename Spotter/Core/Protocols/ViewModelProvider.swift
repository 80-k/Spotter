// ViewModelProvider.swift
// 뷰모델 제공자 프로토콜 정의
// Created by woo on 4/18/25.

import Foundation
import SwiftData

/// 뷰모델 제공 프로토콜
///
/// 앱 전체에서 일관된 뷰모델 인스턴스를 제공하기 위한 프로토콜입니다.
/// 의존성 주입 컨테이너와 함께 사용됩니다.
protocol ViewModelProvider {
    /// 지정한 타입의 뷰모델 반환
    func viewModel<T: ViewModelDataSource>(of type: T.Type) -> T
    
    /// 템플릿 뷰모델 반환
    func templateViewModel() -> any TemplateDataSource
    
    /// 템플릿 액션 핸들러 생성
    func createTemplateActionsHandler(for viewModel: any TemplateDataSource) -> TemplateActionsHandler
    
    /// 비동기 작업 헬퍼 생성
    func createAsyncOperationHelper() -> AsyncOperationHelper
}

/// 기본 구현 확장
extension ViewModelProvider {
    /// 템플릿 액션 핸들러 생성 (기본 구현)
    func createTemplateActionsHandler(for viewModel: any TemplateDataSource) -> TemplateActionsHandler {
        return TemplateActionsHandler(viewModel: viewModel)
    }
    
    /// 비동기 작업 헬퍼 생성 (기본 구현)
    func createAsyncOperationHelper() -> AsyncOperationHelper {
        return AsyncOperationHelper()
    }
    
    /// 템플릿 뷰 컴포넌트 생성 (제네릭 헬퍼)
    func createTemplateViewComponent<T: TemplateViewComponent>(
        type: T.Type = T.self,
        viewModel: T.DataSourceType? = nil
    ) -> T where T.DataSourceType == any TemplateDataSource, T.ActionType == TemplateActionsHandler {
        let vm = viewModel ?? templateViewModel()
        let actions = createTemplateActionsHandler(for: vm)
        return T(viewModel: vm, actions: actions)
    }
}

/// 테스트 지원 확장
extension ViewModelProvider {
    /// 모의 템플릿 뷰모델 생성
    func mockTemplateViewModel() -> MockTemplateViewModel {
        return viewModel(of: MockTemplateViewModel.self)
    }
} 