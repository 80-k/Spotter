// ActorTemplateViewModel+Operations.swift
// 작업 관리 기능을 분리한 확장
// Created by woo on 4/16/25.

import Foundation

// 비동기 작업 관리를 위한 확장
extension ActorTemplateViewModel {
    // MARK: - 내부 속성 
    
    /// 비동기 작업 관리
    var fetchTask: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.fetchTaskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &AssociatedKeys.fetchTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    /// 작업 맵
    var operations: [UUID: Task<Void, Never>] {
        get { 
            objc_getAssociatedObject(self, &AssociatedKeys.operationsKey) as? [UUID: Task<Void, Never>] ?? [:] 
        }
        set { 
            objc_setAssociatedObject(self, &AssociatedKeys.operationsKey, newValue, .OBJC_ASSOCIATION_RETAIN) 
        }
    }
    
    // MARK: - 태스크 관리
    
    /// 모든 비동기 작업 취소
    func cancelAllTasks() {
        fetchTask?.cancel()
        operations.values.forEach { $0.cancel() }
        operations.removeAll()
    }
    
    /// 지정된 ID의 작업 취소
    func cancelOperation(id: UUID) {
        operations[id]?.cancel()
        operations[id] = nil
        updatePendingOperationsCount()
    }
    
    /// 새 작업 추가
    func addOperation<T>(_ operation: @escaping () async throws -> T) -> Task<T, Error> {
        let taskID = UUID()
        let task = Task<T, Error> {
            do {
                updatePendingOperationsCount()
                let result = try await operation()
                cancelOperation(id: taskID)
                return result
            } catch {
                cancelOperation(id: taskID)
                throw error
            }
        }
        
        operations[taskID] = Task {
            do {
                _ = try await task.value
            } catch {
                handleError(error)
            }
        }
        
        updatePendingOperationsCount()
        return task
    }
    
    /// 작업 개수 업데이트
    private func updatePendingOperationsCount() {
        self.pendingOperationsCount = operations.count
    }
}

// 연관 속성 키 (associated objects)
private enum AssociatedKeys {
    static var fetchTaskKey = "ActorTemplateViewModel.fetchTaskKey"
    static var operationsKey = "ActorTemplateViewModel.operationsKey"
} 