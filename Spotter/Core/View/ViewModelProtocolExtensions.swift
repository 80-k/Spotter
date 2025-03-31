import Foundation
import Combine
import SwiftUI

// MARK: - 템플릿 데이터소스 공통 구현

extension TemplateDataSource {
    /// 템플릿 기본 초기화 (공통)
    func initializeDefaultState() {
        self.templates = []
        self.error = nil
    }
    
    /// 템플릿 정렬 (공통)
    func sortTemplates(by option: TemplateSortOption, direction: SortDirection = .descending) -> [WorkoutTemplate] {
        switch option {
        case .name:
            return sortByName(templates, direction: direction)
        case .lastUsed:
            return sortByLastUsed(templates, direction: direction)
        case .useCount:
            return sortByUseCount(templates, direction: direction)
        case .created:
            return sortByCreationDate(templates, direction: direction)
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 템플릿을 이름으로 정렬
    private func sortByName(_ templates: [WorkoutTemplate], direction: SortDirection) -> [WorkoutTemplate] {
        return templates.sorted { first, second in
            let comparison = first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
            return direction == .ascending ? comparison : !comparison
        }
    }
    
    /// 템플릿을 마지막 사용일 기준으로 정렬
    private func sortByLastUsed(_ templates: [WorkoutTemplate], direction: SortDirection) -> [WorkoutTemplate] {
        return templates.sorted { first, second in
            let firstDate = first.lastUsed ?? Date.distantPast
            let secondDate = second.lastUsed ?? Date.distantPast
            let comparison = firstDate > secondDate
            return direction == .descending ? comparison : !comparison
        }
    }
    
    /// 템플릿을 사용 횟수 기준으로 정렬
    private func sortByUseCount(_ templates: [WorkoutTemplate], direction: SortDirection) -> [WorkoutTemplate] {
        return templates.sorted { first, second in
            let comparison = first.useCount > second.useCount
            return direction == .descending ? comparison : !comparison
        }
    }
    
    /// 템플릿을 생성일 기준으로 정렬
    private func sortByCreationDate(_ templates: [WorkoutTemplate], direction: SortDirection) -> [WorkoutTemplate] {
        return templates.sorted { first, second in
            let comparison = first.createDate > second.createDate
            return direction == .descending ? comparison : !comparison
        }
    }
}

// MARK: - 진행중 작업 표시 공통 구현

extension OperationStateReporting where Self: ObservableObject {
    /// 작업 상태 업데이트 기본 구현
    func updateOperationState(delta: Int) {
        if let pending = self as? any ObservableObject {
            DispatchQueue.main.async {
                if let mutableSelf = pending as? Self {
                    if var stateObj = mutableSelf as? (any OperationStateReporting) {
                        let newValue = stateObj.pendingOperationsCount + delta
                        // 반영 로직은 이 프로토콜 구현 클래스에서 직접 구현해야 함
                    }
                }
            }
        }
    }
    
    /// 작업 트래킹 래퍼 - 작업 시작/종료 자동화
    func trackOperation<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        updateOperationState(delta: 1)
        do {
            let result = try await operation()
            updateOperationState(delta: -1)
            return result
        } catch {
            updateOperationState(delta: -1)
            throw error
        }
    }
}

// MARK: - 상태 업데이트 공통 구현

extension RealtimeStateUpdating where Self: ViewModelDataSource {
    /// 다른 데이터소스에서 상태 업데이트 (공통)
    func updateState<T: ViewModelDataSource>(from source: T) {
        DispatchQueue.main.async {
            if let self = self as? TemplateDataSource, 
               let source = source as? TemplateDataSource {
                self.templates = source.templates
                self.error = source.error
            }
            
            if let self = self as? SessionDataSource,
               let source = source as? SessionDataSource {
                // 세션 데이터 업데이트 로직
            }
        }
    }
} 