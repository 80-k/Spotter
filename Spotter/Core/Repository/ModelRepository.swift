// ModelRepository.swift
// SwiftData modelContext 접근을 추상화하는 Repository 패턴 구현
// Created by woo on 4/1/25.

import Foundation
import SwiftData

/// SwiftData의 modelContext 접근을 추상화하는 프로토콜
protocol Repository {
    associatedtype Entity
    
    // 동기 메서드 (Result 타입 반환)
    func getAll() -> Result<[Entity], AppError>
    func getById(_ id: PersistentIdentifier) -> Result<Entity?, AppError>
    func save(_ entity: Entity) -> Result<Void, AppError>
    func delete(_ entity: Entity) -> Result<Void, AppError>
    func update() -> Result<Void, AppError>
    
    // 비동기 메서드 (throws 사용)
    func getAllAsync() async throws -> [Entity]
    func getByIdAsync(_ id: PersistentIdentifier) async throws -> Entity?
    func saveAsync(_ entity: Entity) async throws
    func deleteAsync(_ entity: Entity) async throws
    
    // 비동기 메서드 (Result 타입 반환)
    func getAllAsyncResult() async -> Result<[Entity], AppError>
    func getByIdAsyncResult(_ id: PersistentIdentifier) async -> Result<Entity?, AppError>
    func saveAsyncResult(_ entity: Entity) async -> Result<Void, AppError>
    func deleteAsyncResult(_ entity: Entity) async -> Result<Void, AppError>
}

/// SwiftData를 사용하는 기본 Repository 구현
class ModelRepository<T: PersistentModel>: Repository {
    typealias Entity = T
    
    // private에서 internal로 변경하여 하위 클래스에서 접근 가능하도록 함
    // Swift에는 protected 키워드가 없어 internal이 비슷한 역할
    internal var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - 동기 메서드 (Result 타입 반환)
    
    func getAll() -> Result<[T], AppError> {
        do {
            let descriptor = FetchDescriptor<T>()
            return .success(try modelContext.fetch(descriptor))
        } catch {
            return .failure(.persistenceError("데이터 조회 실패: \(error.localizedDescription)"))
        }
    }
    
    func getById(_ id: PersistentIdentifier) -> Result<T?, AppError> {
        do {
            let descriptor = FetchDescriptor<T>(predicate: #Predicate { $0.id == id })
            let results = try modelContext.fetch(descriptor)
            return .success(results.first)
        } catch {
            return .failure(.persistenceError("ID로 데이터 조회 실패: \(error.localizedDescription)"))
        }
    }
    
    func save(_ entity: T) -> Result<Void, AppError> {
        do {
            modelContext.insert(entity)
            try update().get() // Result의 get() 메서드 활용
            return .success(())
        } catch {
            return .failure(.persistenceError("데이터 저장 실패: \(error.localizedDescription)"))
        }
    }
    
    func delete(_ entity: T) -> Result<Void, AppError> {
        do {
            modelContext.delete(entity)
            try update().get()
            return .success(())
        } catch {
            return .failure(.persistenceError("데이터 삭제 실패: \(error.localizedDescription)"))
        }
    }
    
    func update() -> Result<Void, AppError> {
        do {
            try modelContext.save()
            return .success(())
        } catch {
            return .failure(.persistenceError("컨텍스트 저장 실패: \(error.localizedDescription)"))
        }
    }
    
    // MARK: - 비동기 메서드 (throws 사용)
    
    /// 비동기 방식으로 모든 항목 가져오기
    func getAllAsync() async throws -> [T] {
        try await Task {
            let descriptor = FetchDescriptor<T>()
            return try modelContext.fetch(descriptor)
        }.value
    }
    
    /// 비동기 방식으로 ID로 항목 가져오기
    func getByIdAsync(_ id: PersistentIdentifier) async throws -> T? {
        try await Task {
            let descriptor = FetchDescriptor<T>(predicate: #Predicate { $0.id == id })
            let results = try modelContext.fetch(descriptor)
            return results.first
        }.value
    }
    
    /// 비동기 방식으로 저장하기
    func saveAsync(_ entity: T) async throws {
        try await Task {
            modelContext.insert(entity)
            try modelContext.save()
        }.value
    }
    
    /// 비동기 방식으로 삭제하기
    func deleteAsync(_ entity: T) async throws {
        try await Task {
            modelContext.delete(entity)
            try modelContext.save()
        }.value
    }
    
    // MARK: - 비동기 메서드 (Result 타입 반환)
    
    func getAllAsyncResult() async -> Result<[T], AppError> {
        do {
            return .success(try await getAllAsync())
        } catch {
            return .failure(.persistenceError("비동기 데이터 조회 실패: \(error.localizedDescription)"))
        }
    }
    
    func getByIdAsyncResult(_ id: PersistentIdentifier) async -> Result<T?, AppError> {
        do {
            return .success(try await getByIdAsync(id))
        } catch {
            return .failure(.persistenceError("비동기 ID 조회 실패: \(error.localizedDescription)"))
        }
    }
    
    func saveAsyncResult(_ entity: T) async -> Result<Void, AppError> {
        do {
            try await saveAsync(entity)
            return .success(())
        } catch {
            return .failure(.persistenceError("비동기 저장 실패: \(error.localizedDescription)"))
        }
    }
    
    func deleteAsyncResult(_ entity: T) async -> Result<Void, AppError> {
        do {
            try await deleteAsync(entity)
            return .success(())
        } catch {
            return .failure(.persistenceError("비동기 삭제 실패: \(error.localizedDescription)"))
        }
    }
    
    // MARK: - 유틸리티 메서드
    
    /// 정렬 옵션이 있는 모든 항목 가져오기
    func getAll(sortBy sortDescriptors: [SortDescriptor<T>]) throws -> [T] {
        let descriptor = FetchDescriptor<T>(sortBy: sortDescriptors)
        return try modelContext.fetch(descriptor)
    }
    
    /// 비동기 방식으로 정렬된 항목 가져오기
    func getAllAsync(sortBy sortDescriptors: [SortDescriptor<T>]) async throws -> [T] {
        try await Task {
            let descriptor = FetchDescriptor<T>(sortBy: sortDescriptors)
            return try modelContext.fetch(descriptor)
        }.value
    }
    
    /// 특정 조건으로 필터링된 항목 가져오기
    func find(where predicate: Predicate<T>, sortBy sortDescriptors: [SortDescriptor<T>]? = nil) throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortDescriptors ?? [])
        return try modelContext.fetch(descriptor)
    }
    
    /// 비동기 방식으로 필터링된 항목 가져오기
    func findAsync(where predicate: Predicate<T>, sortBy sortDescriptors: [SortDescriptor<T>]? = nil) async throws -> [T] {
        try await Task {
            let descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortDescriptors ?? [])
            return try modelContext.fetch(descriptor)
        }.value
    }
    
    /// modelContext 업데이트
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
    }
} 