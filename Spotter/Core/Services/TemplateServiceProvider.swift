// TemplateServiceProvider.swift
// 템플릿 관련 서비스 제공자
// Created by woo on 4/19/25.

import Foundation
import SwiftData

/// 템플릿 관련 서비스 제공자
///
/// 템플릿 관련 서비스를 생성하고 등록하는 역할을 담당합니다.
/// DependencyContainer에서 템플릿 관련 책임을 분리하여 단일 책임 원칙을 강화합니다.
final class TemplateServiceProvider {
    // MARK: - 속성
    
    /// 서비스 레지스트리
    private let registry: ServiceRegistry
    
    /// 모델 컨텍스트
    private let modelContext: ModelContext
    
    // MARK: - 초기화
    
    /// 기본 초기화
    init(registry: ServiceRegistry, modelContext: ModelContext) {
        self.registry = registry
        self.modelContext = modelContext
    }
    
    // MARK: - 서비스 등록
    
    /// 템플릿 관련 서비스 등록
    func registerServices() {
        // 템플릿 저장소 등록
        let repository = createTemplateRepository()
        registry.register(repository, for: TemplateRepository.self)
        
        // 템플릿 뷰모델 등록
        registerTemplateViewModel(with: repository)
        
        // 템플릿 관리자 등록
        let templateManager = createTemplateManager(with: repository)
        registry.register(templateManager, for: TemplateManager.self)
    }
    
    // MARK: - 서비스 생성 메서드
    
    /// 템플릿 저장소 생성
    private func createTemplateRepository() -> TemplateRepository {
        return TemplateRepository(modelContext: modelContext)
    }
    
    /// 템플릿 뷰모델 등록
    private func registerTemplateViewModel(with repository: TemplateRepository) {
        let workoutSession = WorkoutSessionManager.shared
        let viewModel = ActorTemplateViewModel(repository: repository, workoutSession: workoutSession)
        
        // 두 가지 프로토콜 타입으로 등록 (역호환성 지원)
        registry.register(viewModel, for: ActorTemplateViewModel.self)
        registry.register(viewModel, for: (any TemplateDataSource).self)
    }
    
    /// 템플릿 관리자 생성
    private func createTemplateManager(with repository: TemplateRepository) -> TemplateManager {
        let operationHelper = registry.resolveOptional(AsyncOperationHelper.self) ?? AsyncOperationHelper()
        return TemplateManager(repository: repository, operationHelper: operationHelper)
    }
    
    // MARK: - 편의 접근 메서드
    
    /// 템플릿 액션 핸들러 생성
    func createTemplateActionsHandler() -> TemplateActionsHandler {
        let viewModel = registry.resolve((any TemplateDataSource).self)
        let operationHelper = registry.resolveOptional(AsyncOperationHelper.self) ?? AsyncOperationHelper()
        return TemplateActionsHandler(viewModel: viewModel, operationHelper: operationHelper)
    }
    
    /// 템플릿 뷰 컴포넌트 생성
    func createTemplateViewComponents() -> (viewModel: any TemplateDataSource, actions: TemplateActionsHandler) {
        let viewModel = registry.resolve((any TemplateDataSource).self)
        let actions = createTemplateActionsHandler()
        return (viewModel, actions)
    }
} 