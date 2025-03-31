// DependencyContainer.swift
// 앱의 의존성 주입을 담당하는 컨테이너
// Created by woo on 4/1/25.

import Foundation
import SwiftData

/// 앱의 의존성 주입을 담당하는 컨테이너 클래스
class DependencyContainer: ObservableObject {
    // 싱글톤 인스턴스
    static let shared = DependencyContainer()
    
    // Repository 컬렉션
    private var repositories: [String: Any] = [:]
    
    // 서비스 컬렉션
    private var services: [String: Any] = [:]
    
    // Actor 컬렉션
    private var actors: [String: Any] = [:]
    
    // 옵저버블한 모델 컨텍스트 (뷰에서 변경 감지 가능)
    @Published private var _modelContext: ModelContext?
    
    // 모델 컨텍스트 접근자
    var modelContext: ModelContext? {
        return _modelContext
    }
    
    private init() {}
    
    /// ModelContext 설정
    func setupModelContext(_ context: ModelContext) {
        self._modelContext = context
        
        // 리포지토리 초기화
        setupRepositories()
        
        // 서비스 초기화
        setupServices()
        
        // 액터 초기화
        setupActors()
    }
    
    /// 기본 리포지토리들 초기화
    private func setupRepositories() {
        guard let context = modelContext else { return }
        
        // 운동 리포지토리
        repositories["exercise"] = ExerciseRepository(modelContext: context)
        
        // 템플릿 리포지토리
        repositories["template"] = TemplateRepository(modelContext: context)
        
        // 세션 리포지토리
        repositories["session"] = SessionRepository(modelContext: context)
    }
    
    /// 기본 서비스들 초기화
    private func setupServices() {
        // 알림 서비스
        services["notification"] = NotificationService()
        
        // 오류 로깅 서비스
        services["errorLog"] = ErrorLogService.shared
        
        // 다른 서비스들 추가
    }
    
    /// 액터 초기화
    private func setupActors() {
        guard let templateRepo = getRepository("template") as? TemplateRepository else { return }
        
        // 템플릿 데이터 액터
        actors["templateData"] = TemplateDataActor(repository: templateRepo)
    }
    
    // MARK: - 내부 액세스 헬퍼
    private func getRepository<T>(_ key: String) -> T? {
        return repositories[key] as? T
    }
    
    private func getService<T>(_ key: String) -> T? {
        return services[key] as? T
    }
    
    private func getActor<T>(_ key: String) -> T? {
        return actors[key] as? T
    }
    
    // MARK: - Repository 액세스 메서드 (기존 메서드 유지)
    
    // ExerciseRepository 반환 (기존 방식)
    func exerciseRepository() -> ExerciseRepository? {
        return getRepository("exercise")
    }
    
    // TemplateRepository 반환 (기존 방식)
    func templateRepository() -> TemplateRepository? {
        return getRepository("template")
    }
    
    // SessionRepository 반환 (기존 방식)
    func sessionRepository() -> SessionRepository? {
        return getRepository("session")
    }
    
    // MARK: - 액터 접근 메서드
    
    // 템플릿 데이터 액터 반환
    func templateDataActor() -> TemplateDataActor? {
        return getActor("templateData")
    }
} 