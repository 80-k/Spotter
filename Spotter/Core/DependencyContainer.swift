// DependencyContainer.swift
// 앱 의존성 컨테이너 구현
// Created by woo on 4/19/25.

import Foundation
import SwiftData

/// 앱 의존성 관리 컨테이너
///
/// 앱 전체에서 사용하는 서비스 프로바이더를 관리하고 초기화하는 클래스입니다.
/// 실제 서비스 인스턴스 관리는 ServiceRegistry에 위임하여 책임을 분산합니다.
final class DependencyContainer: ObservableObject, ViewModelProvider {
    // MARK: - 싱글톤 인스턴스
    
    /// 공유 컨테이너 인스턴스
    static let shared = DependencyContainer()
    
    // MARK: - 속성
    
    /// SwiftData 모델 컨테이너
    private let modelContainer: ModelContainer
    
    /// 서비스 레지스트리
    private let registry: ServiceRegistry
    
    /// 서비스 제공자 목록
    private var serviceProviders: [ServiceProviderProtocol] = []
    
    // MARK: - 초기화
    
    /// 기본 초기화
    init(container: ModelContainer? = nil) {
        do {
            // 모델 컨테이너 초기화
            self.modelContainer = container ?? try ModelContainer(for: WorkoutTemplate.self)
            
            // 서비스 레지스트리 초기화
            self.registry = ServiceRegistry.shared
            
            // 서비스 제공자 등록 및 초기화
            setupServiceProviders()
        } catch {
            fatalError("모델 컨테이너 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 서비스 제공자 설정
    
    /// 서비스 제공자 설정
    private func setupServiceProviders() {
        // 기본 서비스 등록
        registerCoreServices()
        
        // 템플릿 관련 서비스 등록
        let templateProvider = TemplateServiceProvider(registry: registry, modelContext: modelContainer.mainContext)
        serviceProviders.append(templateProvider)
        templateProvider.registerServices()
        
        // TODO: 다른 서비스 프로바이더 추가 시 여기에 등록
    }
    
    /// 기본 서비스 등록
    private func registerCoreServices() {
        // 오류 처리 서비스 등록
        registry.register(ErrorHandlingService.shared, for: ErrorHandlingService.self)
        
        // 비동기 작업 헬퍼 등록
        registry.register(AsyncOperationHelper(), for: AsyncOperationHelper.self)
        
        // 모델 컨텍스트 등록
        registry.register(modelContainer.mainContext, for: ModelContext.self)
        
        // 의존성 컨테이너 자신을 등록
        registry.register(self, for: ViewModelProvider.self)
    }
    
    // MARK: - ViewModelProvider 구현
    
    /// 지정한 타입의 뷰모델 반환
    func viewModel<ViewModelType: ViewModelDataSource>(of type: ViewModelType.Type = ViewModelType.self) -> ViewModelType {
        return registry.resolve(type)
    }
    
    /// 템플릿 뷰모델 반환
    func templateViewModel() -> any TemplateDataSource {
        return registry.resolve((any TemplateDataSource).self)
    }
    
    /// 템플릿 액션 핸들러 생성
    func createTemplateActionsHandler(for viewModel: any TemplateDataSource) -> TemplateActionsHandler {
        let templateProvider = getServiceProvider(of: TemplateServiceProvider.self)
        return templateProvider.createTemplateActionsHandler()
    }
    
    /// 비동기 작업 헬퍼 생성
    func createAsyncOperationHelper() -> AsyncOperationHelper {
        return registry.resolve(AsyncOperationHelper.self)
    }
    
    // MARK: - 서비스 제공자 접근
    
    /// 특정 타입의 서비스 제공자 가져오기
    private func getServiceProvider<ProviderType: ServiceProviderProtocol>(of type: ProviderType.Type) -> ProviderType {
        guard let provider = serviceProviders.first(where: { $0 is ProviderType }) as? ProviderType else {
            fatalError("요청한 서비스 제공자가 등록되지 않았습니다: \(type)")
        }
        return provider
    }
}

// MARK: - 서비스 제공자 프로토콜

/// 서비스 제공자 기본 프로토콜
protocol ServiceProviderProtocol {
    /// 서비스 등록
    func registerServices()
}

// MARK: - 테스트 지원

extension DependencyContainer {
    /// 테스트 컨테이너 생성
    static func testContainer() -> DependencyContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            let container = try ModelContainer(for: WorkoutTemplate.self, configurations: config)
            return DependencyContainer(container: container)
        } catch {
            fatalError("테스트 컨테이너 생성 실패: \(error.localizedDescription)")
        }
    }
} 