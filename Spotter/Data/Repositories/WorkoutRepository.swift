// WorkoutRepository.swift
// 운동 저장소 구현
//  Created by woo on 3/30/25.

import Foundation
import SwiftData
import Combine

/// 운동 관련 데이터 접근을 위한 리포지토리 구현
final class WorkoutRepository: WorkoutRepositoryProtocol {
    private let modelContext: ModelContext
    
    @MainActor
    init(modelContext: ModelContext? = nil) {
        // 모델 컨텍스트가 주입되지 않으면 기본 컨텍스트 사용
        if let context = modelContext {
            self.modelContext = context
        } else {
            self.modelContext = SwiftDataManager.shared.sharedModelContainer.mainContext
        }
    }
    
    // MARK: - 템플릿 관련
    
    func fetchWorkoutTemplates() -> AnyPublisher<[WorkoutTemplate], Error> {
        Future<[WorkoutTemplate], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextUnavailable))
                return
            }
            
            do {
                let descriptor = FetchDescriptor<WorkoutTemplate>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
                let templates = try self.modelContext.fetch(descriptor)
                promise(.success(templates))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func saveWorkoutTemplate(_ template: WorkoutTemplate) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextUnavailable))
                return
            }
            
            do {
                if template.modelContext == nil {
                    self.modelContext.insert(template)
                }
                try self.modelContext.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteWorkoutTemplate(_ template: WorkoutTemplate) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextUnavailable))
                return
            }
            
            do {
                self.modelContext.delete(template)
                try self.modelContext.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - 세션 관련
    
    func fetchWorkoutSessions() -> AnyPublisher<[WorkoutSession], Error> {
        Future<[WorkoutSession], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextUnavailable))
                return
            }
            
            do {
                let descriptor = FetchDescriptor<WorkoutSession>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
                let sessions = try self.modelContext.fetch(descriptor)
                promise(.success(sessions))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func saveWorkoutSession(_ session: WorkoutSession) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextUnavailable))
                return
            }
            
            do {
                if session.modelContext == nil {
                    self.modelContext.insert(session)
                }
                try self.modelContext.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteWorkoutSession(_ session: WorkoutSession) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextUnavailable))
                return
            }
            
            do {
                self.modelContext.delete(session)
                try self.modelContext.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - 운동 항목 관련
    
    func fetchExerciseItems() -> AnyPublisher<[ExerciseItem], Error> {
        Future<[ExerciseItem], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextUnavailable))
                return
            }
            
            do {
                let descriptor = FetchDescriptor<ExerciseItem>(sortBy: [SortDescriptor(\.name)])
                let exercises = try self.modelContext.fetch(descriptor)
                promise(.success(exercises))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func saveExerciseItem(_ exerciseItem: ExerciseItem) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextUnavailable))
                return
            }
            
            do {
                if exerciseItem.modelContext == nil {
                    self.modelContext.insert(exerciseItem)
                }
                try self.modelContext.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - 에러 정의

enum RepositoryError: Error {
    case contextUnavailable
    case entityNotFound
    case saveFailed
    case deleteFailed
    
    var localizedDescription: String {
        switch self {
        case .contextUnavailable:
            return "데이터 컨텍스트를 사용할 수 없습니다."
        case .entityNotFound:
            return "요청한 엔티티를 찾을 수 없습니다."
        case .saveFailed:
            return "데이터 저장에 실패했습니다."
        case .deleteFailed:
            return "데이터 삭제에 실패했습니다."
        }
    }
} 