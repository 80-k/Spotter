// TaskManager.swift
// 비동기 작업 관리 클래스
// Created by woo on 4/18/25.

import Foundation

/// 비동기 작업을 관리하는 클래스
///
/// 이 클래스는 뷰모델에서 수행하는 비동기 작업을 추적하고 관리합니다.
/// 작업 추가, 취소 및 완료 상태 추적 기능을 제공합니다.
final class TaskManager {
    // MARK: - 속성

    /// 데이터 로드용 태스크
    var fetchTask: Task<Void, Never>?
    
    /// 진행 중인 작업 사전 (작업 ID -> 태스크)
    private(set) var operations = [UUID: Task<Void, Never>]()
    
    /// 작업 상태 변화 알림을 위한 콜백
    var onOperationCountChanged: ((Int) -> Void)?
    
    /// 현재 진행 중인 작업 수
    var pendingOperationsCount: Int {
        return operations.count
    }
    
    // MARK: - 작업 관리
    
    /// 모든 작업 취소
    func cancelAll() {
        fetchTask?.cancel()
        operations.values.forEach { $0.cancel() }
        operations.removeAll()
        
        notifyCountChanged()
    }
    
    /// 특정 작업 취소
    func cancelOperation(id: UUID) {
        operations[id]?.cancel()
        operations[id] = nil
        
        notifyCountChanged()
    }
    
    /// 새 작업 추가 및 추적
    func addOperation<T>(_ operation: @escaping () async throws -> T, errorHandler: @escaping (Error) -> Void) -> Task<T, Error> {
        let taskID = UUID()
        
        // 작업 생성
        let task = Task<T, Error> {
            do {
                notifyCountChanged()
                let result = try await operation()
                cancelOperation(id: taskID)
                return result
            } catch {
                cancelOperation(id: taskID)
                throw error
            }
        }
        
        // 에러 처리 및 모니터링 작업 추가
        operations[taskID] = Task {
            do {
                _ = try await task.value
            } catch {
                errorHandler(error)
            }
        }
        
        notifyCountChanged()
        return task
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 작업 개수 변경 시 알림
    private func notifyCountChanged() {
        onOperationCountChanged?(pendingOperationsCount)
    }
}

/// 테스트용 빈 작업 관리자 확장
extension TaskManager {
    /// 테스트용 모의 객체 생성
    static var mock: TaskManager {
        let manager = TaskManager()
        manager.onOperationCountChanged = { _ in }
        return manager
    }
} 