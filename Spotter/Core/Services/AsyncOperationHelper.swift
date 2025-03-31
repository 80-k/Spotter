// AsyncOperationHelper.swift
// 비동기 작업 단순화 헬퍼 기능
// Created by woo on 4/18/25.

import Foundation
import SwiftUI
import Combine

/// 비동기 작업의 상태를 표현하는 열거형
enum AsyncOperationState: Equatable {
    case idle
    case loading
    case success
    case failure(Error)
    
    static func == (lhs: AsyncOperationState, rhs: AsyncOperationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

/// 비동기 작업의 결과를 래핑하는 타입
enum AsyncResult<SuccessType> {
    case success(SuccessType)
    case failure(Error)
    
    /// 성공 값 추출
    var value: SuccessType? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
    
    /// 오류 추출
    var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}

/// 비동기 작업을 단순화하는 헬퍼 클래스
final class AsyncOperationHelper: ObservableObject {
    // MARK: - 속성
    
    /// 현재 작업 상태
    @Published private(set) var state: AsyncOperationState = .idle
    
    /// 작업 ID 생성기
    private var operationCounter: Int = 0
    
    /// 현재 활성화된 작업들
    private var activeOperations: [Int: Task<Void, Never>] = [:]
    
    /// 오류 처리 서비스
    private let errorService: ErrorHandlingService
    
    // MARK: - 초기화
    
    /// 기본 초기화
    init(errorService: ErrorHandlingService = ErrorHandlingService.shared) {
        self.errorService = errorService
    }
    
    // MARK: - 작업 관리
    
    /// 모든 작업 취소
    func cancelAllOperations() {
        for (_, task) in activeOperations {
            task.cancel()
        }
        activeOperations.removeAll()
        
        if case .loading = state {
            state = .idle
        }
    }
    
    /// 비동기 작업 실행
    /// - Parameters:
    ///   - operation: 실행할 비동기 작업
    ///   - updateState: 상태 업데이트 여부 (기본값: true)
    ///   - handleError: 오류 처리 여부 (기본값: true)
    ///   - logLevel: 오류 로그 레벨 (기본값: .error)
    ///   - file: 호출 소스 파일
    ///   - line: 호출 소스 라인
    /// - Returns: 작업 결과
    @discardableResult
    func execute<ResultType>(
        operation: @escaping () async throws -> ResultType,
        updateState: Bool = true,
        handleError: Bool = true,
        logLevel: ErrorHandlingService.LogLevel = .error,
        file: String = #file,
        line: Int = #line
    ) async -> AsyncResult<ResultType> {
        if updateState {
            await updateToLoadingState()
        }
        
        let operationId = generateOperationId()
        
        do {
            let result = try await withTaskCancellationHandler {
                try await operation()
            } onCancel: {
                // 취소 처리
            }
            
            removeOperation(id: operationId)
            
            if updateState {
                await updateToSuccessState()
            }
            
            return .success(result)
        } catch {
            removeOperation(id: operationId)
            
            if handleError {
                await handleOperationError(error, logLevel: logLevel, file: file, line: line)
            }
            
            return .failure(error)
        }
    }
    
    /// 비동기 작업 수행 (작업 ID 반환)
    @discardableResult
    func performOperation<ResultType>(
        updateState: Bool = true,
        handleError: Bool = true,
        logLevel: ErrorHandlingService.LogLevel = .error,
        file: String = #file,
        line: Int = #line,
        operation: @escaping () async throws -> ResultType
    ) -> Int {
        let operationId = generateOperationId()
        
        let task = Task {
            if updateState {
                await updateToLoadingState()
            }
            
            do {
                let _ = try await operation()
                
                if Task.isCancelled { return }
                
                if updateState {
                    await updateToSuccessState()
                }
            } catch {
                if Task.isCancelled { return }
                
                if handleError {
                    await handleOperationError(error, logLevel: logLevel, file: file, line: line)
                }
            }
            
            removeOperation(id: operationId)
        }
        
        activeOperations[operationId] = task
        return operationId
    }
    
    /// 특정 작업 취소
    func cancelOperation(id: Int) {
        guard let task = activeOperations[id] else { return }
        task.cancel()
        activeOperations.removeValue(forKey: id)
    }
    
    // MARK: - 상태 관리 헬퍼 메서드
    
    /// 로딩 상태로 업데이트
    private func updateToLoadingState() async {
        await MainActor.run { state = .loading }
    }
    
    /// 성공 상태로 업데이트
    private func updateToSuccessState() async {
        await MainActor.run { state = .success }
    }
    
    /// 오류 처리
    private func handleOperationError(
        _ error: Error,
        logLevel: ErrorHandlingService.LogLevel,
        file: String,
        line: Int
    ) async {
        await MainActor.run {
            errorService.handle(
                error,
                level: logLevel,
                file: file,
                line: line
            )
            
            state = .failure(error)
        }
    }
    
    // MARK: - 도움 메서드
    
    /// 새 작업 ID 생성
    private func generateOperationId() -> Int {
        operationCounter += 1
        return operationCounter
    }
    
    /// 활성 작업 목록에서 작업 제거
    private func removeOperation(id: Int) {
        activeOperations.removeValue(forKey: id)
    }
}

// MARK: - 테스트 지원

extension AsyncOperationHelper {
    /// 테스트용 목 인스턴스 생성
    static func mockInstance() -> AsyncOperationHelper {
        return AsyncOperationHelper()
    }
} 