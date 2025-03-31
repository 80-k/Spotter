// ViewModelProvider.swift
// 뷰모델 제공을 위한 프로토콜
// Created by woo on 4/16/25.

import Foundation
import SwiftData
import Combine

/// 뷰모델 인스턴스를 제공하는 프로토콜
protocol ViewModelProvider {
    /// 모델 컨텍스트
    var modelContext: ModelContext { get }
    
    /// 캐시된 뷰모델 저장소
    var cachedViewModels: [String: AnyObject] { get set }
    
    /// 타입에 따른 뷰모델 반환 또는 생성
    func viewModel<T: ViewModelDataSource>(of type: T.Type) -> T
    
    /// 식별자에 따른 뷰모델 반환
    func viewModel<T: ViewModelDataSource>(for id: String) -> T?
    
    /// 뷰모델 캐싱
    func cacheViewModel<T: ViewModelDataSource>(_ viewModel: T)
    
    /// 캐시 초기화
    func clearViewModelCache()
    
    /// 레포지토리 생성
    func makeRepository<T: RepositoryProtocol>() -> T
}

/// 기본 구현 제공
extension ViewModelProvider {
    /// 템플릿 데이터소스 기반 뷰모델 요청
    func templateViewModel<T: TemplateDataSource>() -> T {
        return viewModel(of: T.self)
    }
    
    /// 세션 데이터소스 기반 뷰모델 요청
    func sessionViewModel<T: SessionDataSource>() -> T {
        return viewModel(of: T.self)
    }
    
    /// 캐시된 뷰모델 확인 및 반환 (없으면 nil)
    func viewModel<T: ViewModelDataSource>(for id: String) -> T? {
        return cachedViewModels[id] as? T
    }
    
    /// 타입을 기반으로 한 캐시 키
    func cacheKey<T: ViewModelDataSource>(for type: T.Type) -> String {
        return type.identifier
    }
    
    /// 뷰모델을 캐시에 저장
    func cacheViewModel<T: ViewModelDataSource>(_ viewModel: T) {
        let key = cacheKey(for: T.self)
        cachedViewModels[key] = viewModel
    }
    
    /// 캐시 초기화
    func clearViewModelCache() {
        cachedViewModels.removeAll()
    }
    
    /// 템플릿 리포지토리 생성 (편의 메서드)
    func makeTemplateRepository() -> TemplateRepository {
        return makeRepository()
    }
    
    /// 세션 리포지토리 생성 (편의 메서드)
    func makeSessionRepository() -> SessionRepository {
        return makeRepository()
    }
}

/// DependencyContainer 확장
extension DependencyContainer: ViewModelProvider {
    /// 타입에 따른 뷰모델 요청 (캐시 확인 후 없으면 생성)
    func viewModel<T: ViewModelDataSource>(of type: T.Type) -> T {
        let key = cacheKey(for: type)
        
        // 캐시된 뷰모델이 있으면 반환
        if let cachedVM = viewModel(for: key) {
            return cachedVM
        }
        
        // 타입별 뷰모델 생성 로직
        let newViewModel: T
        
        if let type = type as? ActorTemplateViewModel.Type {
            // 액터 템플릿 뷰모델 생성
            let repo = makeTemplateRepository()
            let sessionRepo = makeSessionRepository()
            let vm = ActorTemplateViewModel(repository: repo, sessionRepository: sessionRepo) as! T
            newViewModel = vm
        } else if let type = type as? AsyncTemplateViewModel.Type {
            // 비동기 템플릿 뷰모델 생성
            let repo = makeTemplateRepository()
            let vm = AsyncTemplateViewModel(repository: repo) as! T
            newViewModel = vm
        } else {
            // 기본 생성 방식 시도 (일반적인 경우)
            fatalError("지원되지 않는 뷰모델 타입: \(type)")
        }
        
        // 캐시에 저장 후 반환
        cacheViewModel(newViewModel)
        return newViewModel
    }
} 