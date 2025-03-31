// TemplateDataSource.swift
// 템플릿 관련 데이터 소스 및 액션 프로토콜
// Created by woo on 4/15/25.

import Foundation
import SwiftData

/// 데이터 로딩 상태를 나타내는 열거형
public enum LoadingState {
    case idle
    case loading
    case loaded
    case error(AppError)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var error: AppError? {
        if case .error(let error) = self { return error }
        return nil
    }
}

/// 모든 데이터소스를 위한 기본 프로토콜
protocol DataSource: AnyObject, ObservableObject {
    /// 로딩 상태
    var isLoading: Bool { get }
    
    /// 오류 상태
    var error: AppError? { get set }
    
    /// 오류 초기화
    func clearError()
    
    /// 데이터 새로고침
    func refreshCache()
}

/// 기본 DataSource 구현
extension DataSource {
    /// 기본 오류 초기화 구현
    func clearError() {
        error = nil
    }
}

/// 템플릿 목록 데이터를 제공하는 데이터 소스 프로토콜
protocol TemplateDataSource: DataSource {
    /// 모든 템플릿 목록
    var templates: [WorkoutTemplate] { get set }
    
    /// 최근 사용한 템플릿 목록
    var recentlyUsedTemplates: [WorkoutTemplate] { get }
    
    /// 템플릿 목록 로드
    func loadTemplates()
    
    /// 템플릿 추가
    func addTemplate(name: String) async throws -> WorkoutTemplate
    
    /// 템플릿 업데이트
    func updateTemplate(_ template: WorkoutTemplate)
    
    /// 템플릿 삭제
    func deleteTemplate(_ template: WorkoutTemplate)
    
    /// 템플릿 검색
    func searchTemplates(query: String) async throws -> [WorkoutTemplate]
    
    /// 운동 세션 시작
    func startWorkout(with template: WorkoutTemplate) async throws -> WorkoutSession?
    
    /// 다른 데이터 소스로부터 상태 업데이트
    func updateState(from source: TemplateDataSource)
}

/// 기본 TemplateDataSource 구현
extension TemplateDataSource {
    /// 최근 사용한 템플릿의 기본 구현
    var recentlyUsedTemplates: [WorkoutTemplate] {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        return templates.filter { template in
            guard let lastUsed = template.lastUsed else { return false }
            return lastUsed > thirtyDaysAgo
        }.sorted { ($0.lastUsed ?? Date.distantPast) > ($1.lastUsed ?? Date.distantPast) }
    }
    
    /// 다른 데이터 소스로부터 상태 업데이트하는 기본 구현
    func updateState(from source: TemplateDataSource) {
        Task { @MainActor in
            self.templates = source.templates
            self.error = source.error
        }
    }
}

/// 템플릿 관련 액션을 처리하는 델리게이트 프로토콜
protocol TemplateActionDelegate: AnyObject, ObservableObject {
    /// 템플릿 선택 및 운동 시작
    func selectAndStartWorkout(template: WorkoutTemplate)
    
    /// 템플릿 삭제 요청
    func requestDeleteTemplate(template: WorkoutTemplate)
    
    /// 데이터 새로고침
    func refreshData() async
    
    /// 템플릿 추가
    func addTemplate()
    
    /// 템플릿 삭제 확인
    func confirmDeleteTemplate()
    
    /// 다이얼로그 취소
    func cancelDialog()
    
    /// 템플릿 검색
    func searchTemplates()
    
    /// 다이얼로그 상태
    var showingAddTemplate: Bool { get set }
    var showingDeleteConfirmation: Bool { get set }
    
    /// 네비게이션 상태
    var navigateToActiveWorkout: Bool { get set }
    
    /// 액티브 세션
    var activeWorkoutSession: WorkoutSession? { get }
    
    /// 사용자 입력
    var searchText: String { get set }
    var newTemplateName: String { get set }
}

/// 기본 TemplateActionDelegate 구현
extension TemplateActionDelegate {
    /// 기본 다이얼로그 취소 구현
    func cancelDialog() {
        newTemplateName = ""
        showingAddTemplate = false
        showingDeleteConfirmation = false
    }
}

/// 템플릿 뷰모델 팩토리 인터페이스
protocol TemplateViewModelFactory {
    /// ActorTemplateViewModel 생성
    func makeActorTemplateViewModel() -> ActorTemplateViewModel?
    
    /// TemplateRepository 생성
    func makeTemplateRepository() -> TemplateRepository
} 