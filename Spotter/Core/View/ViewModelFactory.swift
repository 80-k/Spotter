import Foundation
import SwiftUI
import Combine

/// 모든 뷰모델 팩토리의 기본 프로토콜 
/// - 뷰모델을 생성하고 관리하기 위한 표준 인터페이스 정의
protocol ViewModelFactory {
    /// 팩토리가 생성하는 뷰모델 타입
    associatedtype ViewModelType: AnyObject
    
    /// 사용 가능한 뷰모델을 생성하거나 기존 인스턴스 반환
    func makeViewModel() -> ViewModelType
    
    /// 특정 ID의 뷰모델을 반환하거나 생성
    func viewModel(for id: String) -> ViewModelType?
    
    /// 뷰모델을 캐시에 저장
    func cacheViewModel(_ viewModel: ViewModelType, for id: String)
    
    /// 캐시된 모든 뷰모델 인스턴스 제거
    func clearCache()
}

// MARK: - 템플릿 뷰모델 팩토리

/// 템플릿 관련 뷰모델을 생성하는 팩토리
protocol TemplateViewModelFactory: ViewModelFactory {
    /// 액터 기반 템플릿 뷰모델 생성
    func makeActorTemplateViewModel() -> ActorTemplateViewModel
    
    /// 비동기 템플릿 뷰모델 생성
    func makeAsyncTemplateViewModel() -> AsyncTemplateViewModel
    
    /// 템플릿 세부 정보 뷰모델 생성
    func makeTemplateDetailViewModel(for template: WorkoutTemplate) -> TemplateDetailViewModel
}

// MARK: - 세션 뷰모델 팩토리

/// 운동 세션 관련 뷰모델을 생성하는 팩토리
protocol SessionViewModelFactory: ViewModelFactory {
    /// 운동 세션 뷰모델 생성
    func makeSessionViewModel(for session: WorkoutSession) -> WorkoutSessionViewModel
    
    /// 운동 기록 뷰모델 생성
    func makeHistoryViewModel() -> WorkoutHistoryViewModel
}

// MARK: - 기본 구현

extension ViewModelFactory {
    /// 뷰모델 생성 시 기본 식별자로 캐싱
    func cacheViewModel(_ viewModel: ViewModelType, forType type: ViewModelType.Type) {
        let id = String(describing: type)
        cacheViewModel(viewModel, for: id)
    }
}

// MARK: - 의존성 컨테이너 확장

extension DependencyContainer {
    /// 기본 뷰모델 식별자로 캐시에 저장
    func cacheViewModel<T: AnyObject>(_ viewModel: T) {
        let id = String(describing: T.self)
        cachedViewModels[id] = viewModel
    }
    
    /// 식별자로 캐시된 뷰모델 검색
    func cachedViewModel<T: AnyObject>(for id: String) -> T? {
        return cachedViewModels[id] as? T
    }
    
    /// 타입으로 캐시된 뷰모델 검색
    func cachedViewModel<T: AnyObject>(ofType type: T.Type) -> T? {
        let id = String(describing: type)
        return cachedViewModels[id] as? T
    }
} 