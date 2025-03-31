// ViewState.swift
// 뷰 상태 관리용 열거형
// Created by woo on 4/16/25.

import Foundation
import SwiftUI

/// 데이터 기반 뷰 상태 열거형
///
/// 뷰모델의 상태에 따라 UI를 어떻게 표시할지 결정하는 데 사용됩니다.
/// 상태 처리 로직을 단순화하고 가독성을 높이는 역할을 합니다.
enum ViewState: Equatable {
    /// 로딩 중 상태
    case loading
    
    /// 데이터가 비어있는 상태
    case empty
    
    /// 정상적으로 데이터를 표시할 수 있는 상태
    case content
    
    /// 오류 발생 상태
    case error(AppError)
    
    /// 두 ViewState가 동일한지 비교
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.empty, .empty), (.content, .content):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
    
    /// TemplateDataSource로부터 ViewState 생성
    static func from<T: TemplateDataSource>(_ viewModel: T) -> ViewState {
        if viewModel.isLoading {
            return .loading
        } else if let error = viewModel.error {
            return .error(error)
        } else if viewModel.templates.isEmpty {
            return .empty
        } else {
            return .content
        }
    }
    
    /// SessionDataSource로부터 ViewState 생성
    static func from<T: SessionDataSource>(_ viewModel: T) -> ViewState {
        if viewModel.isLoading {
            return .loading
        } else if let error = viewModel.error {
            return .error(error)
        } else if viewModel.sessions.isEmpty {
            return .empty
        } else {
            return .content
        }
    }
    
    /// 일반 ViewModelDataSource로부터 ViewState 생성
    static func from<T: ViewModelDataSource>(_ viewModel: T, isEmpty: Bool) -> ViewState {
        if viewModel.isLoading {
            return .loading
        } else if let error = viewModel.error {
            return .error(error)
        } else if isEmpty {
            return .empty
        } else {
            return .content
        }
    }
}

/// ViewState에 대응하는 뷰를 제공하는 뷰 수정자
struct ViewStateContainer<Loading: View, Empty: View, Content: View, Error: View>: ViewModifier {
    let state: ViewState
    let loadingView: Loading
    let emptyView: Empty
    let contentView: Content
    let errorView: (AppError) -> Error
    
    func body(content: Content) -> some View {
        switch state {
        case .loading:
            loadingView
        case .empty:
            emptyView
        case .content:
            contentView
        case .error(let error):
            errorView(error)
        }
    }
}

/// 뷰 확장을 통한 상태 기반 렌더링
extension View {
    /// 상태에 따라 다른 뷰를 표시
    func withViewState<Loading: View, Empty: View, Error: View>(
        state: ViewState,
        @ViewBuilder loading: () -> Loading,
        @ViewBuilder empty: () -> Empty,
        @ViewBuilder error: @escaping (AppError) -> Error
    ) -> some View {
        modifier(
            ViewStateContainer(
                state: state,
                loadingView: loading(),
                emptyView: empty(),
                contentView: self,
                errorView: error
            )
        )
    }
    
    /// TemplateDataSource 뷰모델 상태에 따라 다른 뷰 표시
    func withTemplateState<T: TemplateDataSource, Loading: View, Empty: View, Error: View>(
        viewModel: T,
        @ViewBuilder loading: () -> Loading,
        @ViewBuilder empty: () -> Empty,
        @ViewBuilder error: @escaping (AppError) -> Error
    ) -> some View {
        let state = ViewState.from(viewModel)
        return withViewState(
            state: state,
            loading: loading,
            empty: empty,
            error: error
        )
    }
} 