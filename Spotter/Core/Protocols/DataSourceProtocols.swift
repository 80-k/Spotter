// DataSourceProtocols.swift
// 단순화된 프로토콜 계층 구조
// Created by woo on 4/18/25.

import Foundation
import Combine
import SwiftData

// MARK: - 기본 데이터 소스 프로토콜

/// 모든 뷰모델 데이터 소스의 기본 프로토콜
protocol ViewModelDataSource: AnyObject, ObservableObject {
    /// 이 뷰모델의 고유 식별자
    static var identifier: String { get }
    
    /// 뷰모델이 현재 로딩 중인지 여부
    var isLoading: Bool { get }
    
    /// 뷰모델에서 발생한 오류
    var error: AppError? { get set }
    
    /// 오류 상태 초기화
    func clearError()
}

// MARK: - 템플릿 관리 프로토콜

/// 템플릿 데이터 관리 기능을 정의하는 프로토콜
protocol TemplateManagement {
    /// 이 데이터소스가 제공하는 템플릿 목록
    var templates: [WorkoutTemplate] { get set }
    
    /// 최근 사용한 템플릿 목록
    var recentlyUsedTemplates: [WorkoutTemplate] { get }
    
    /// 템플릿 목록 로드
    func loadTemplates()
    
    /// 템플릿 데이터 새로고침
    func refreshCache() async
    
    /// 새 템플릿 추가
    @discardableResult
    func addTemplate(name: String) async throws -> WorkoutTemplate
    
    /// 템플릿 삭제
    func deleteTemplate(_ template: WorkoutTemplate) async throws
    
    /// 템플릿으로 운동 세션 시작
    @discardableResult
    func startWorkout(with template: WorkoutTemplate) async throws -> WorkoutSession?
    
    /// 이름으로 템플릿 검색
    func searchTemplates(matching query: String) async
}

// MARK: - 작업 관리 프로토콜

/// 진행 중인 작업 상태 관리 프로토콜
protocol OperationManagement {
    /// 현재 진행 중인 백그라운드 작업 수
    var pendingOperationsCount: Int { get }
    
    /// 작업 상태 업데이트
    func updateOperationState(delta: Int)
    
    /// 새 작업 추가
    func addOperation<T>(_ operation: @escaping () async throws -> T) -> Task<T, Error>
    
    /// 모든 작업 취소
    func cancelAllOperations()
}

// MARK: - 기타 기능 프로토콜

/// 실시간 상태 업데이트 기능 제공 프로토콜
protocol StateUpdateable {
    /// 다른 뷰모델에서 데이터 상태 동기화
    func updateState<T: ViewModelDataSource>(from source: T)
}

// MARK: - 합성 프로토콜 (타입 별칭)

/// 템플릿 데이터 소스 (기본 + 템플릿 관리)
typealias TemplateDataSource = ViewModelDataSource & TemplateManagement

/// 작업 관리 기능을 포함한 템플릿 뷰모델
typealias TemplateOperationalViewModel = TemplateDataSource & OperationManagement & StateUpdateable

// MARK: - 기본 구현

extension ViewModelDataSource {
    /// 기본 식별자는 클래스 이름 기반
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    /// 오류 상태 초기화
    func clearError() {
        self.error = nil
    }
}

extension TemplateManagement {
    /// 최근 사용한 템플릿의 기본 구현
    var recentlyUsedTemplates: [WorkoutTemplate] {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        return templates.filter { template in
            guard let lastUsed = template.lastUsed else { return false }
            return lastUsed > thirtyDaysAgo
        }.sorted { ($0.lastUsed ?? Date.distantPast) > ($1.lastUsed ?? Date.distantPast) }
    }
} 