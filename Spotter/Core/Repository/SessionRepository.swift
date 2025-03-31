// SessionRepository.swift
// WorkoutSession 모델에 특화된 Repository 구현
// Created by woo on 4/1/25.

import Foundation
import SwiftData

class SessionRepository: ModelRepository<WorkoutSession> {
    /// 템플릿으로 운동 세션 생성 및 저장
    func createSession(with template: WorkoutTemplate) throws -> WorkoutSession {
        let session = WorkoutSession(template: template)
        
        // 세션에 템플릿의 운동들 추가
        template.exercises?.forEach { exercise in
            session.addExercise(exercise)
        }
        
        try save(session)
        return session
    }
    
    /// 템플릿으로 운동 세션 생성 및 저장 (비동기)
    func createSessionAsync(with template: WorkoutTemplate) async throws -> WorkoutSession {
        let session = WorkoutSession(template: template)
        
        // 세션에 템플릿의 운동들 추가
        template.exercises?.forEach { exercise in
            session.addExercise(exercise)
        }
        
        try await saveAsync(session)
        return session
    }
    
    /// 완료된 세션만 가져오기
    func getCompletedSessions() throws -> [WorkoutSession] {
        try find(where: #Predicate { $0.endTime != nil })
    }
    
    /// 완료된 세션만 가져오기 (비동기)
    func getCompletedSessionsAsync() async throws -> [WorkoutSession] {
        try await findAsync(where: #Predicate { $0.endTime != nil })
    }
    
    /// 진행 중인 세션만 가져오기 
    func getActiveSessions() throws -> [WorkoutSession] {
        try find(where: #Predicate { $0.endTime == nil })
    }
    
    /// 진행 중인 세션만 가져오기 (비동기)
    func getActiveSessionsAsync() async throws -> [WorkoutSession] {
        try await findAsync(where: #Predicate { $0.endTime == nil })
    }
    
    /// 특정 날짜 범위의 세션 가져오기
    func getSessions(from startDate: Date, to endDate: Date) throws -> [WorkoutSession] {
        try find(where: #Predicate { 
            $0.startTime >= startDate && $0.startTime <= endDate
        }, sortBy: [SortDescriptor(\.startTime, order: .reverse)])
    }
    
    /// 특정 날짜 범위의 세션 가져오기 (비동기)
    func getSessionsAsync(from startDate: Date, to endDate: Date) async throws -> [WorkoutSession] {
        try await findAsync(where: #Predicate { 
            $0.startTime >= startDate && $0.startTime <= endDate
        }, sortBy: [SortDescriptor(\.startTime, order: .reverse)])
    }
    
    /// 특정 템플릿으로 생성된 세션들 가져오기
    func getSessions(forTemplate templateId: PersistentIdentifier) throws -> [WorkoutSession] {
        try find(where: #Predicate { $0.template?.id == templateId })
    }
    
    /// 특정 템플릿으로 생성된 세션들 가져오기 (비동기)
    func getSessionsAsync(forTemplate templateId: PersistentIdentifier) async throws -> [WorkoutSession] {
        try await findAsync(where: #Predicate { $0.template?.id == templateId })
    }
}

// MARK: - RepositoryProtocol 구현

extension SessionRepository: SessionRepositoryProtocol {} 