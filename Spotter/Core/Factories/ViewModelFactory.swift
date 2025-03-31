// ViewModelFactory.swift
// 뷰모델 팩토리 통합 
// Created by woo on 4/18/25.

import Foundation
import SwiftData

/// 모든 뷰모델 팩토리의 기본 프로토콜
protocol ViewModelFactory {
    /// 모델 컨텍스트 제공
    var modelContext: ModelContext { get }
}

/// 템플릿 뷰모델 팩토리 프로토콜
protocol TemplateViewModelFactory: ViewModelFactory {
    /// 템플릿 뷰모델 생성
    func createTemplateViewModel() -> any TemplateDataSource
    
    /// 템플릿 뷰 컴포넌트 생성
    func createTemplateViewComponents() -> (viewModel: any TemplateDataSource, actions: TemplateActionsHandler)
}

/// 세션 뷰모델 팩토리 프로토콜
protocol SessionViewModelFactory: ViewModelFactory {
    /// 세션 뷰모델 생성
    func createSessionViewModel() -> any SessionViewModel
}

/// 뷰모델 동기화 유틸리티 프로토콜
protocol ViewModelSyncUtility {
    /// 뷰모델 간 상태 동기화
    func syncViewModels<T: StateUpdateable, U: StateUpdateable>(source: T, target: U)
}

// MARK: - 기본 구현

extension TemplateViewModelFactory {
    /// 템플릿 뷰모델 생성 기본 구현
    func createTemplateViewModel() -> any TemplateDataSource {
        let repository = TemplateRepository(modelContext: modelContext)
        let workoutSession = WorkoutSessionManager.shared
        return ActorTemplateViewModel(repository: repository, workoutSession: workoutSession)
    }
    
    /// 템플릿 뷰 컴포넌트 생성 기본 구현
    func createTemplateViewComponents() -> (viewModel: any TemplateDataSource, actions: TemplateActionsHandler) {
        let viewModel = createTemplateViewModel()
        let actions = TemplateActionsHandler(viewModel: viewModel)
        return (viewModel, actions)
    }
}

extension SessionViewModelFactory {
    /// 세션 뷰모델 생성 기본 구현
    func createSessionViewModel() -> any SessionViewModel {
        let repository = SessionRepository(modelContext: modelContext)
        return SessionViewModel(repository: repository)
    }
}

extension ViewModelSyncUtility {
    /// 뷰모델 간 상태 동기화 기본 구현
    func syncViewModels<T: StateUpdateable, U: StateUpdateable>(source: T, target: U) {
        target.syncState(from: source)
    }
} 