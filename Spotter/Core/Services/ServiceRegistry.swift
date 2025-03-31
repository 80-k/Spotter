// ServiceRegistry.swift
// 서비스 등록 및 해결 담당 클래스
// Created by woo on 4/19/25.

import Foundation
import SwiftData

/// 서비스 등록 및 해결 담당 클래스
///
/// 애플리케이션의 다양한 서비스 인스턴스를 등록하고 해결하는 역할을 담당합니다.
/// DependencyContainer의 책임을 분산하여 의존성 관리를 단순화합니다.
final class ServiceRegistry {
    // MARK: - 싱글톤 인스턴스
    
    /// 공유 인스턴스
    static let shared = ServiceRegistry()
    
    // MARK: - 속성
    
    /// 서비스 인스턴스 저장소
    private var services: [String: Any] = [:]
    
    /// 팩토리 함수 저장소
    private var factories: [String: () -> Any] = [:]
    
    // MARK: - 서비스 등록
    
    /// 서비스 인스턴스 등록
    /// - Parameters:
    ///   - service: 등록할 서비스 인스턴스
    ///   - type: 서비스 타입
    func register<ServiceType>(_ service: ServiceType, for type: ServiceType.Type) {
        let key = String(describing: type)
        services[key] = service
    }
    
    /// 지연 생성 서비스 등록
    /// - Parameters:
    ///   - factory: 서비스 생성 팩토리 함수
    ///   - type: 서비스 타입
    func registerFactory<ServiceType>(_ factory: @escaping () -> ServiceType, for type: ServiceType.Type) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    // MARK: - 서비스 해결
    
    /// 서비스 인스턴스 해결
    /// - Parameter type: 서비스 타입
    /// - Returns: 해당 타입의 서비스 인스턴스
    func resolve<ServiceType>(_ type: ServiceType.Type = ServiceType.self) -> ServiceType {
        let key = String(describing: type)
        
        // 이미 생성된 인스턴스가 있는지 확인
        if let service = services[key] as? ServiceType {
            return service
        }
        
        // 팩토리 함수가 있는지 확인
        if let factory = factories[key] {
            let service = factory() as! ServiceType
            services[key] = service  // 생성된 인스턴스 캐시
            return service
        }
        
        fatalError("요청한 서비스 타입이 등록되지 않았습니다: \(key)")
    }
    
    /// 서비스 인스턴스 해결 (옵셔널)
    /// - Parameter type: 서비스 타입
    /// - Returns: 해당 타입의 서비스 인스턴스 (없으면 nil)
    func resolveOptional<ServiceType>(_ type: ServiceType.Type = ServiceType.self) -> ServiceType? {
        let key = String(describing: type)
        
        if let service = services[key] as? ServiceType {
            return service
        }
        
        if let factory = factories[key] {
            let service = factory() as! ServiceType
            services[key] = service
            return service
        }
        
        return nil
    }
    
    /// 모든 서비스 초기화
    func reset() {
        services.removeAll()
    }
} 