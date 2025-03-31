// TemplateViewComponent.swift
// 템플릿 뷰 컴포넌트 프로토콜
// Created by woo on 4/18/25.

import SwiftUI

/// 템플릿 관련 뷰 컴포넌트를 위한 공통 프로토콜
///
/// 템플릿 관련 뷰 컴포넌트를 정의하고 구현하기 위한 프로토콜입니다.
/// 이 프로토콜을 구현하면 데이터 소스와 액션 핸들러 간의 관계가 명확하게 정의됩니다.
protocol TemplateViewComponent {
    /// 데이터 소스 타입
    associatedtype DataSourceType: TemplateDataSource
    
    /// 액션 핸들러 타입
    associatedtype ActionType: TemplateActionDelegate
    
    /// 뷰모델 (데이터 소스)
    var viewModel: DataSourceType { get }
    
    /// 액션 핸들러
    var actions: ActionType { get }
    
    /// 초기화
    func initialize()
    
    /// 데이터 새로고침
    func refreshData() async
    
    /// 템플릿 추가 다이얼로그 표시
    func showAddDialog()
    
    /// 오류 처리
    func handleError(_ error: Error?)
}

/// 기본 구현 제공
extension TemplateViewComponent {
    /// 기본 초기화 구현
    func initialize() {
        // 데이터가 비어있고 로딩 중이 아닌 경우에만 새로고침
        if viewModel.templates.isEmpty && !viewModel.isLoading {
            Task {
                await refreshData()
            }
        }
    }
    
    /// 기본 데이터 새로고침 구현
    func refreshData() async {
        do {
            try await viewModel.refreshTemplates()
        } catch {
            handleError(error)
        }
    }
    
    /// 기본 템플릿 추가 다이얼로그 표시 구현
    func showAddDialog() {
        actions.showAddDialog()
    }
    
    /// 기본 오류 처리 구현
    func handleError(_ error: Error?) {
        if let error = error {
            // 오류 핸들링 서비스에 위임
            ErrorHandlingService.shared.handle(error: error)
        }
    }
}

/// SwiftUI View용 확장
extension View {
    /// 템플릿 뷰 초기화 수정자
    func withTemplateInitialization<T: TemplateViewComponent>(_ component: T) -> some View {
        self.onAppear {
            component.initialize()
        }
    }
} 