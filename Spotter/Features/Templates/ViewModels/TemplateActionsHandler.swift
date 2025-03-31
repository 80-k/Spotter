// TemplateActionsHandler.swift
// 템플릿 액션 처리기 구현
// Created by woo on 4/18/25.

import Foundation
import SwiftUI
import Combine

/// 템플릿 액션 위임 프로토콜
///
/// 템플릿 관련 사용자 액션을 처리하기 위한 프로토콜입니다.
protocol TemplateActionDelegate: ObservableObject {
    // MARK: - 상태 속성
    
    /// 검색어
    var searchText: String { get set }
    
    /// 현재 선택된 템플릿
    var selectedTemplate: WorkoutTemplate? { get set }
    
    /// 현재 활성화된 워크아웃 세션
    var activeWorkoutSession: WorkoutSession? { get set }
    
    /// 템플릿 추가 다이얼로그 표시 여부
    var isShowingAddDialog: Bool { get set }
    
    /// 템플릿 삭제 확인 다이얼로그 표시 여부
    var isShowingDeleteConfirmation: Bool { get set }
    
    /// 활성 워크아웃으로 이동 여부
    var navigateToActiveWorkout: Bool { get set }
    
    // MARK: - 액션 메서드
    
    /// 템플릿 추가
    func addTemplate()
    
    /// 템플릿 선택
    func selectTemplate(_ template: WorkoutTemplate)
    
    /// 템플릿 편집
    func editTemplate(_ template: WorkoutTemplate)
    
    /// 템플릿 삭제 요청
    func requestDeleteTemplate(_ template: WorkoutTemplate)
    
    /// 템플릿 삭제 확인
    func confirmDeleteTemplate()
    
    /// 새 템플릿 추가 다이얼로그 표시
    func showAddDialog()
    
    /// 다이얼로그 취소
    func cancelDialogs()
}

/// 템플릿 액션 처리기
final class TemplateActionsHandler: ObservableObject, TemplateActionDelegate {
    // MARK: - 발행 속성
    
    @Published var searchText: String = ""
    @Published var selectedTemplate: WorkoutTemplate?
    @Published var activeWorkoutSession: WorkoutSession?
    @Published var isShowingAddDialog: Bool = false
    @Published var isShowingDeleteConfirmation: Bool = false
    @Published var navigateToActiveWorkout: Bool = false
    
    // MARK: - 내부 속성
    
    /// 비동기 작업 헬퍼
    private let operationHelper: AsyncOperationHelper
    
    /// 뷰모델 (데이터 소스)
    private let viewModel: any TemplateDataSource
    
    /// 취소 토큰
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 초기화
    
    /// 기본 초기화
    init(
        viewModel: any TemplateDataSource,
        operationHelper: AsyncOperationHelper = AsyncOperationHelper()
    ) {
        self.viewModel = viewModel
        self.operationHelper = operationHelper
        
        setupSearch()
    }
    
    // MARK: - 액션 구현
    
    /// 템플릿 추가
    func addTemplate() {
        let newTemplateName = "새 템플릿 \(Date().formatted(date: .abbreviated, time: .shortened))"
        
        operationHelper.performOperation {
            try await self.viewModel.addTemplate(name: newTemplateName)
        }
    }
    
    /// 템플릿 선택 및 워크아웃 시작
    func selectTemplate(_ template: WorkoutTemplate) {
        self.selectedTemplate = template
        
        // 워크아웃 세션 시작 구현 (임시)
        let session = WorkoutSession(template: template)
        self.activeWorkoutSession = session
        self.navigateToActiveWorkout = true
    }
    
    /// 템플릿 편집
    func editTemplate(_ template: WorkoutTemplate) {
        // 여기에 템플릿 편집 로직 구현
        self.selectedTemplate = template
    }
    
    /// 템플릿 삭제 요청
    func requestDeleteTemplate(_ template: WorkoutTemplate) {
        self.selectedTemplate = template
        self.isShowingDeleteConfirmation = true
    }
    
    /// 템플릿 삭제 확인
    func confirmDeleteTemplate() {
        guard let template = selectedTemplate else { return }
        
        operationHelper.performOperation {
            try await self.viewModel.deleteTemplate(template)
            await MainActor.run {
                self.selectedTemplate = nil
            }
        }
    }
    
    /// 새 템플릿 추가 다이얼로그 표시
    func showAddDialog() {
        isShowingAddDialog = true
    }
    
    /// 다이얼로그 취소
    func cancelDialogs() {
        isShowingAddDialog = false
        isShowingDeleteConfirmation = false
    }
    
    // MARK: - 검색 설정
    
    /// 검색 기능 설정
    private func setupSearch() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                self.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    /// 검색 실행
    private func performSearch(query: String) {
        operationHelper.performOperation {
            try await self.viewModel.searchTemplates(query: query)
        }
    }
}

// MARK: - 테스트 지원

extension TemplateActionsHandler {
    /// 테스트용 목 인스턴스 생성
    static func mockInstance(viewModel: any TemplateDataSource = MockTemplateViewModel()) -> TemplateActionsHandler {
        return TemplateActionsHandler(viewModel: viewModel)
    }
} 