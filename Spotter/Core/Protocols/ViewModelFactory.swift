// ViewModelFactory.swift
// 뷰모델 및 관련 컴포넌트 생성을 위한 팩토리 프로토콜
// Created by woo on 4/15/25.

import Foundation
import SwiftData

/// 모든 뷰모델 팩토리를 위한 기본 프로토콜
protocol ViewModelFactory {
    /// 팩토리가 사용할 모델 컨텍스트 반환
    var modelContext: ModelContext { get }
    
    /// 리포지토리 생성을 위한 헬퍼 메서드
    func makeRepository<T: NSObject>() -> T where T: RepositoryProtocol
}

/// 기본 구현
extension ViewModelFactory {
    /// 템플릿 리포지토리 생성
    func makeTemplateRepository() -> TemplateRepository {
        makeRepository()
    }
    
    /// 세션 리포지토리 생성
    func makeSessionRepository() -> SessionRepository {
        makeRepository()
    }
}

/// 템플릿 뷰모델 팩토리 인터페이스
protocol TemplateViewModelFactory: ViewModelFactory {
    /// ActorTemplateViewModel 생성
    func makeActorTemplateViewModel() -> ActorTemplateViewModel?
    
    /// 템플릿 액션 핸들러 생성
    func makeTemplateActionsHandler(for viewModel: TemplateDataSource) -> TemplateActionsHandler
    
    /// 템플릿 뷰모델과 액션 핸들러를 함께 생성
    func makeTemplateViewComponents() -> (viewModel: ActorTemplateViewModel, actions: TemplateActionsHandler)
}

/// 운동 세션 뷰모델 팩토리 인터페이스 
protocol SessionViewModelFactory: ViewModelFactory {
    /// 세션 리포지토리 생성
    func makeSessionRepository() -> SessionRepository
}

/// 뷰모델 동기화 유틸리티
protocol ViewModelSyncUtility {
    /// 두 뷰모델 간에 속성 동기화
    func syncViewModels<T: DataSource>(source: T, target: T)
}

/// 기본 구현
extension ViewModelSyncUtility {
    /// 데이터소스 뷰모델 동기화 기본 구현
    func syncViewModels<T: DataSource>(source: T, target: T) {
        Task { @MainActor in
            if let sourceTemplate = source as? TemplateDataSource,
               let targetTemplate = target as? TemplateDataSource {
                targetTemplate.updateState(from: sourceTemplate)
            } else {
                // 기본 속성만 동기화
                target.error = source.error
            }
        }
    }
} 